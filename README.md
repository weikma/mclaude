# mclaude

> 阿里云 AI Coding Plan适配工具，一条命令快速切换多种大模型后端。

---

## 前置条件

本工具预设你已安装 **Claude Code**。如尚未安装，请先执行以下命令：

**macOS / Linux / WSL**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows PowerShell**

```powershell
irm https://claude.ai/install.ps1 | iex
```

---

## 功能

- 专为**阿里云 Coding Plan**设计，完美适配其多模型服务
- 一条命令快速切换 AI 后端（Qwen / GLM / Kimi / MiniMax）
- 自动注入 `ANTHROPIC_BASE_URL` 与 `ANTHROPIC_AUTH_TOKEN`
- **完全屏蔽** `~/.claude/settings.json` 中的原有配置，避免冲突

---

## 对比官方教程

阿里云官方教程的做法是将环境变量**永久写入系统**，这会覆盖 Claude Code 原有的配置，导致无法再使用原生的 Anthropic 服务。

mclaude 只在**启动进程时**临时注入环境变量，不修改任何系统或用户级配置，因此：

- 切换到阿里云模型：`mclaude qwen`
- 回到原本的 Claude Code 配置：`mclaude`（不加任何参数）

两种模式随时切换，互不干扰。

---

## 安装

脚本可以放在任意位置，安装时只需将软链接或别名指向脚本的实际路径即可。

### macOS / Linux

```bash
# 赋予执行权限
chmod +x /path/to/mclaude.sh

# 将实际路径软链接到 PATH 下（示例放在 ~/tools/ 目录）
sudo ln -sf /path/to/mclaude.sh /usr/local/bin/mclaude
```

### Windows（PowerShell）

**1. 允许执行本地脚本**（如已设置可跳过）

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**2. 创建永久别名**，将脚本实际路径写入 PowerShell 配置文件

```powershell
# 将下面路径替换为 mclaude.ps1 的实际位置
Add-Content $PROFILE "`nSet-Alias mclaude 'C:\path\to\mclaude.ps1'"
```

重启 PowerShell 后生效。

---

## 用法

```bash
mclaude <模型> [claude 原生参数...]
```

| 命令 | 效果 |
|------|------|
| `mclaude qwen` | 固定使用 Qwen 模型启动 |
| `mclaude glm` | 固定使用 GLM 模型启动 |
| `mclaude kimi` | 固定使用 Kimi 模型启动 |
| `mclaude minimax` | 固定使用 MiniMax 模型启动 |
| `mclaude` | 不注入任何配置，使用系统默认配置启动 |

**示例**

```bash
mclaude kimi
mclaude qwen --dangerously-skip-permissions
```

---

## 配置

### macOS / Linux

编辑 `mclaude.sh` 顶部的变量：

```bash
ANTHROPIC_BASE_URL="https://..."      # API 地址
ANTHROPIC_AUTH_TOKEN="sk-..."         # API Key

MODEL_QWEN="qwen-coder-plus"
MODEL_GLM="glm-4"
MODEL_KIMI="kimi-k2.5"
MODEL_MINIMAX="abab6.5-chat"
```

### Windows（PowerShell）

编辑 `mclaude.ps1` 顶部的变量：

```powershell
$ANTHROPIC_BASE_URL  = "https://..."   # API 地址
$ANTHROPIC_AUTH_TOKEN = "sk-..."       # API Key

$MODEL_QWEN    = "qwen-coder-plus"
$MODEL_GLM     = "glm-4"
$MODEL_KIMI    = "kimi-k2.5"
$MODEL_MINIMAX = "abab6.5-chat"
```

---

## 如何屏蔽 settings.json

`~/.claude/settings.json` 中的 `env` 块由 Claude Code **进程内部**写入 `process.env`，会在启动后覆盖 shell 预设的同名变量；`apiKeyHelper` 也会替换认证 Token。

mclaude 通过两个机制彻底绕过：

```
--setting-sources project,local
```
> 只加载项目级与本地级配置，跳过 user 级别的 `~/.claude/settings.json`，
> 使其中的 `env.ANTHROPIC_BASE_URL` 与 `apiKeyHelper` 永远不会被执行。

```
--model <model-name>
```
> 通过 CLI flag 直接指定模型，优先级高于任何配置文件中的 `model` 字段。

最终生效的启动命令形如：

```bash
ANTHROPIC_BASE_URL="..." ANTHROPIC_AUTH_TOKEN="..." \
  claude --setting-sources project,local --model kimi-k2.5
```

---

## 阿里云 AI 贺岁活动

![阿里云 AI 贺岁邀客有礼](poster.png)

🎁 **限时福利**：通过上方二维码或 [专属链接](https://www.aliyun.com/benefit/ai/aistar?clubBiz=subTask..12409005..10263..) 注册阿里云账号，即可领取 **10 元 AI 编程优惠券**，畅享多模型智能编程体验！
