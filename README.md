# mclaude

> 阿里云 AI 编程计划适配工具，一条命令快速切换多种大模型后端。

---

## 功能

- 专为**阿里云 AI 编程计划**设计，完美适配其多模型服务
- 一条命令快速切换 AI 后端（Qwen / GLM / Kimi / MiniMax）
- 自动注入 `ANTHROPIC_BASE_URL` 与 `ANTHROPIC_AUTH_TOKEN`
- **完全屏蔽** `~/.claude/settings.json` 中的原有配置，避免冲突

---

## 安装

```bash
chmod +x ~/.claude/mclaude.sh
sudo ln -sf ~/.claude/mclaude.sh /usr/local/bin/mclaude
```

---

## 用法

```bash
mclaude <模型> [claude 原生参数...]
```

| 命令 | 模型 |
|------|------|
| `mclaude qwen` | Qwen |
| `mclaude glm` | GLM |
| `mclaude kimi` | Kimi |
| `mclaude minimax` | MiniMax |
| `mclaude` | 不切换，使用系统默认配置 |

**示例**

```bash
mclaude kimi
mclaude qwen --dangerously-skip-permissions
```

---

## 配置

编辑 `~/.claude/mclaude.sh` 顶部的变量：

```bash
ANTHROPIC_BASE_URL="https://..."      # API 地址
ANTHROPIC_AUTH_TOKEN="sk-..."         # API Key

MODEL_QWEN="qwen-coder-plus"
MODEL_GLM="glm-4"
MODEL_KIMI="kimi-k2.5"
MODEL_MINIMAX="abab6.5-chat"
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
