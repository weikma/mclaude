#!/usr/bin/env bash
# mclaude - 多模型 Claude Code 启动器
# 用法: mclaude [qwen|glm|kimi|minimax] [claude 其他参数...]
#
# 安装: chmod +x mclaude.sh && sudo ln -sf "$(realpath mclaude.sh)" /usr/local/bin/mclaude

# ===== 公共配置 =====
ANTHROPIC_BASE_URL="https://coding.dashscope.aliyuncs.com/apps/anthropic"
ANTHROPIC_AUTH_TOKEN=""   # ← 填入你的 API Key

# ===== 各模型 Model Name =====
MODEL_QWEN="qwen3.5-plus"
MODEL_GLM="glm-5"
MODEL_KIMI="kimi-k2.5"
MODEL_MINIMAX="MiniMax-M2.5"

# ===== claude 可执行文件路径 =====
CLAUDE_BIN="$(which claude 2>/dev/null || echo "/Users/weikun.ma/.claude/local/node_modules/.bin/claude")"

# ============================================================
# 以下逻辑无需修改
# ============================================================

usage() {
    cat <<EOF
用法: mclaude [模型] [claude 参数...]

模型选项:
  qwen      使用 Qwen 模型    ($MODEL_QWEN)
  glm       使用 GLM  模型    ($MODEL_GLM)
  kimi      使用 Kimi  模型   ($MODEL_KIMI)
  minimax   使用 MiniMax 模型 ($MODEL_MINIMAX)
  (省略)    不注入任何环境变量，使用系统默认配置启动 Claude Code

示例:
  mclaude qwen
  mclaude glm --dangerously-skip-permissions
  mclaude              # 直接启动，不切换模型
EOF
}

MODEL_ARG="$1"
case "$MODEL_ARG" in
    qwen)
        ANTHROPIC_MODEL="$MODEL_QWEN"
        shift
        ;;
    glm)
        ANTHROPIC_MODEL="$MODEL_GLM"
        shift
        ;;
    kimi)
        ANTHROPIC_MODEL="$MODEL_KIMI"
        shift
        ;;
    minimax)
        ANTHROPIC_MODEL="$MODEL_MINIMAX"
        shift
        ;;
    -h|--help|help)
        usage
        exit 0
        ;;
    "")
        # 无参数，直接启动
        exec "$CLAUDE_BIN" "$@"
        ;;
    -*)
        # 以 - 开头说明是 claude 自己的参数，不做模型切换
        exec "$CLAUDE_BIN" "$@"
        ;;
    *)
        echo "mclaude: 未知模型 '$MODEL_ARG'" >&2
        usage >&2
        exit 1
        ;;
esac

# 注入环境变量并启动
# --setting-sources project,local：跳过 ~/.claude/settings.json（user 级别），
# 避免其中的 env.ANTHROPIC_BASE_URL 和 apiKeyHelper 在进程内覆盖我们设置的值。
exec env \
    ANTHROPIC_BASE_URL="$ANTHROPIC_BASE_URL" \
    ANTHROPIC_AUTH_TOKEN="$ANTHROPIC_AUTH_TOKEN" \
    "$CLAUDE_BIN" \
    --setting-sources project,local \
    --model "$ANTHROPIC_MODEL" \
    "$@"
