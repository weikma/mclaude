# mclaude.ps1 - 多模型 Claude Code 启动器 (Windows PowerShell 版)
# 用法: mclaude [qwen|glm|kimi|minimax|aliyun] [claude 其他参数...]
#
# 安装:
#   1. 将本文件放置到任意目录，例如 C:\Tools\mclaude.ps1
#   2. 将该目录加入 PATH，或创建别名：
#        Set-Alias mclaude "C:\Tools\mclaude.ps1"
#      （建议写入 $PROFILE 以永久生效）
#   3. 确保 PowerShell 允许执行脚本：
#        Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# ===== 公共配置 =====
$ANTHROPIC_BASE_URL = "https://coding.dashscope.aliyuncs.com/apps/anthropic"
$ANTHROPIC_AUTH_TOKEN = ""   # ← 填入你的 API Key

# ===== 各模型 Model Name =====
$MODEL_QWEN    = "qwen3.5-plus"
$MODEL_GLM     = "glm-5"
$MODEL_KIMI    = "kimi-k2.5"
$MODEL_MINIMAX = "MiniMax-M2.5"

# ===== claude 可执行文件路径 =====
$CLAUDE_BIN = (Get-Command claude -ErrorAction SilentlyContinue)?.Source
if (-not $CLAUDE_BIN) {
    $fallback = "$env:APPDATA\npm\claude.cmd"
    if (Test-Path $fallback) {
        $CLAUDE_BIN = $fallback
    } else {
        Write-Error "mclaude: 找不到 claude 可执行文件，请确认已安装 Claude Code。"
        exit 1
    }
}

# ============================================================
# 以下逻辑无需修改
# ============================================================

function Show-Usage {
    Write-Host @"
用法: mclaude [模型] [claude 参数...]

模型选项:
  qwen      使用 Qwen 模型    ($MODEL_QWEN)
  glm       使用 GLM  模型    ($MODEL_GLM)
  kimi      使用 Kimi  模型   ($MODEL_KIMI)
  minimax   使用 MiniMax 模型 ($MODEL_MINIMAX)
  aliyun    注入阿里云凭证但不固定模型，在 Claude Code 内用 /model 切换
  (省略)    不注入任何环境变量，使用系统默认配置启动 Claude Code

示例:
  mclaude qwen
  mclaude glm --dangerously-skip-permissions
  mclaude aliyun       # 启动后在 Claude Code 内用 /model 切换模型
  mclaude              # 直接启动，不切换模型
"@
}

function Ensure-Onboarding {
    $claudeJson = "$env:USERPROFILE\.claude.json"
    if (-not (Test-Path $claudeJson)) {
        '{"hasCompletedOnboarding": true}' | Set-Content -Encoding UTF8 $claudeJson
    } else {
        $content = Get-Content $claudeJson -Raw | ConvertFrom-Json
        if (-not $content.hasCompletedOnboarding) {
            $content | Add-Member -NotePropertyName hasCompletedOnboarding -NotePropertyValue $true -Force
            $content | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $claudeJson
        }
    }
}

# 解析第一个参数
$modelArg = $args[0]
$restArgs  = if ($args.Count -gt 1) { $args[1..($args.Count - 1)] } else { @() }

$selectedModel = $null

switch ($modelArg) {
    "qwen"    { $selectedModel = $MODEL_QWEN;    break }
    "glm"     { $selectedModel = $MODEL_GLM;     break }
    "kimi"    { $selectedModel = $MODEL_KIMI;    break }
    "minimax" { $selectedModel = $MODEL_MINIMAX; break }
    "aliyun" {
        # 注入阿里云凭证但不固定模型，在 Claude Code 内用 /model 切换
        Ensure-Onboarding
        $env:ANTHROPIC_BASE_URL   = $ANTHROPIC_BASE_URL
        $env:ANTHROPIC_AUTH_TOKEN = $ANTHROPIC_AUTH_TOKEN
        & $CLAUDE_BIN --setting-sources project,local @restArgs
        exit $LASTEXITCODE
    }
    { $_ -in @("-h", "--help", "help") } {
        Show-Usage
        exit 0
    }
    ""        {
        # 无参数，直接启动（不覆盖任何环境变量）
        Ensure-Onboarding
        & $CLAUDE_BIN @restArgs
        exit $LASTEXITCODE
    }
    { $_ -like "-*" } {
        # 以 - 开头说明是 claude 自己的参数，不做模型切换
        Ensure-Onboarding
        & $CLAUDE_BIN @args
        exit $LASTEXITCODE
    }
    default {
        Write-Error "mclaude: 未知模型 '$modelArg'"
        Show-Usage
        exit 1
    }
}

# 确保 onboarding 已完成
Ensure-Onboarding

# 注入环境变量并启动
# --setting-sources project,local：跳过 ~/.claude/settings.json（user 级别），
# 避免其中的 env.ANTHROPIC_BASE_URL 和 apiKeyHelper 在进程内覆盖我们设置的值。
$env:ANTHROPIC_BASE_URL  = $ANTHROPIC_BASE_URL
$env:ANTHROPIC_AUTH_TOKEN = $ANTHROPIC_AUTH_TOKEN

& $CLAUDE_BIN --setting-sources project,local --model $selectedModel @restArgs
exit $LASTEXITCODE
