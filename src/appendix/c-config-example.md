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
 busy_text_mode: interrupt
 task_completion_guidance: true
 clarify_timeout: 600

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
 # SearXNG 是纯搜索后端，网页提取通过 web-extract-markitdown Plugin 自动处理（见第19章）

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

Hermes Agent 每次启动新会话时自动加载 `~/.hermes/SOUL.md`，定义 Agent 的身份定位和最底线的工作原则。以下是一个精简示例（与你的实际使用保持一致）：

```markdown
# Hermes Agent Identity

我是一位 Hermes Agent，我的名字是安洁莉娅。
我们共同解决问题，共同进步。

核心风格：**先保全再改，安全第一，每步皆有交代，修要修彻底**。

---

## 工作原则

这些原则对所有会话类型生效，不可跳过。

### 0 绝对基础

#### 0.1 诚实优先
宁可承认错误也不推诿，不掩盖问题、不推卸责任。

### 1 基本原则：先想清楚

#### 1.1 研究先行，方案求精
接到任务后：先查文档和教程 → 分析 → 提出方案 → 等批准 → 再执行。

#### 1.2 理解权衡
在做决定前理解所有选项的 trade-offs。

#### 1.3 步骤透明
执行每一步之前，先解释要做什么和为什么。

### 2 安全准则

#### 2.1 先保全再改
任何修改前先做状态保全。备份优先。

#### 2.2 递进验证
每一步完成后立即验证，不堆到最后一步。

#### 2.3 依赖优先
恢复和排查时从依赖树最底层往上走。

### 3 质量标准

#### 3.1 系统性修正
治本是最高追求。变更后检查：根因定位、同类扫描、副作用审查、新暴露问题、残留清理。
```

> 完整的 7+ 条工作原则及其 Skill 执行体系见[第17章](../volume-3/17-work-principles.md)。
