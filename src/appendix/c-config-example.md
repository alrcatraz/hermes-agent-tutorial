# 附录C：完整配置示例 {#appendix:c}

## C.1 config.yaml 示例

```yaml
model:
 default: deepseek-v4-flash
 provider: deepseek
 base_url: https://api.deepseek.com/v1

agent:
  max_turns: 90
  gateway_timeout: 1800
  task_completion_guidance: true
  clarify_timeout: 600

display:
  busy_text_mode: interrupt
  busy_input_mode: interrupt

delegation:
 provider: deepseek
 model: deepseek-v4-pro
 base_url: ''
 api_key: ''

memory:
 memory_enabled: true
 user_profile_enabled: true
 memory_char_limit: 4000
 user_char_limit: 2500
 provider: holographic
 nudge_interval: 10

auxiliary:
  vision:
   provider: zai
   model: GLM-4V-Flash
   timeout: 120
 web_extract:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 360
 compression:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 120
 skills_hub:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 30
 approval:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 30
 mcp:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 30
 title_generation:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 30
 triage_specifier:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 120
 kanban_decomposer:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 180
 profile_describer:
  provider: zai
  model: GLM-4.7-Flash
  timeout: 60
 curator:
  provider: deepseek
  model: deepseek-v4-pro
  base_url: ''
  api_key: ''

mcp_servers:
 markitdown:
  command: markitdown-mcp
  timeout: 60
  enabled: true
 astra-knowledge-base:
  command: uv run --directory /path/to/astra-knowledge-base-mcp server.py
  enabled: true

plugins:
 enabled:
   - context-anchor
   - web-extract-markitdown

web:
 search_backend: searxng
 # SearXNG 是纯搜索后端，网页提取通过 web-extract-markitdown Plugin 自动处理

display:
 personality: mentor
```

## C.2 .env 示例

```bash
# 主模型 API 密钥（必配）
DEEPSEEK_API_KEY=<Your DeepSeek API Key>
# 辅助任务 API 密钥（推荐，免费）
GLM_API_KEY=<Your GLM/Z.AI API Key>
# Mistral（可选，免费额度）
MISTRAL_API_KEY=<Your Mistral API Key>

# 搜索后端（自建 SearXNG 时需要）
SEARXNG_URL=http://127.0.0.2:8931

# Gateway（按需配置）
TELEGRAM_BOT_TOKEN=<Your Telegram Bot Token>
MATRIX_ACCESS_TOKEN=<Your Matrix Bot Account Token>
MATRIX_RECOVERY_KEY=<Your Matrix Bot Account Recovery Key>
```

## C.3 SOUL.md 示例

Hermes Agent 每次启动新会话时自动加载 `~/.hermes/SOUL.md`，定义 Agent 的身份定位和最底线的行为准则。以下是基于 Hermes 默认模板的示例：

```markdown
# 我的 SOUL 文件

此文件定义我的身份、价值观和工作风格。
每次会话开始时自动加载，作为系统提示词的永久部分。

## 身份

我是一个 AI 助手，用于自动化和问题解决。
我的风格：先想清楚再动手，每一步都验证。

## 核心原则

### 诚实第一
- 如果我不确定，直接说不知道
- 不捏造结果，不掩盖错误

### 安全优先
- 修改前先备份
- 不确定的操作先问用户

### 渐进验证
- 每完成一步就验证，不等到最后
- 从底层依赖开始排查
```

> 你可以在 `~/.hermes/SOUL.md` 中放入任何你觉得对 AGENT 重要的行为准则——Hermes 会在每轮对话开始时自动注入该文件的内容。

