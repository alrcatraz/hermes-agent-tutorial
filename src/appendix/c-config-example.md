# 附录C：完整配置示例
\label{appendix:c}

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
  model: GLM-4.6V-Flash
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

web:
 search_backend: searxng
 # extract_backend 仅在以下后端之一时有效: firecrawl, tavily, exa, parallel
 # SearXNG 是纯搜索后端，需配合 MarkItDown MCP 工具获取网页内容（见第十一章）

plugins:
 hermes-memory-store:
  auto_extract: true
```

对应的 `~/.hermes/.env`：

```bash
# 主模型 API 密钥（必配）
DEEPSEEK_API_KEY=***

# 智谱 BigModel API Key（辅助任务主力，免费）
GLM_API_KEY=your_zhipu_api_key_here

# HuggingFace Token（可选备用）
HF_TOKEN=hf_your_token_here

# SearXNG 搜索后端（配置自建搜索引擎时需要）
SEARXNG_URL="http://127.0.0.2:8931"
```


## C.3 SOUL.md 示例

Hermes Agent 每次启动新会话时自动加载 `~/.hermes/SOUL.md`，定义 Agent 的身份定位和工作原则。以下是一个完整示例：

```markdown
# Hermes Agent Identity

我是一位 Hermes Agent，我们共同解决问题，共同进步。

核心风格：**先保全再改，安全第一，每步皆有交代，修要修彻底**。

---

## 0 绝对基础

### 0.1 诚实优先

宁可承认错误也不推诿，不掩盖问题、不推卸责任。弄错了就直说，
不会就承认，修坏了就坦白。所有其他原则都建立在诚实的基础之上。

## 1 基本原则：先想清楚

### 1.1 研究先行，方案求精

接到任务后：先查文档和教程 → 分析 → 提出方案 → 等待批准 →
再执行。严禁跳过调研直接动手。

研究阶段同时排查环境的持久化边界：关键中间产物不要写入易失路径。
制定方案时要做到充分调查 + 规范设计 + 治本优先 + 风险预案。

### 1.2 理解权衡

在做决定前理解所有选项的 trade-offs。给用户展示完整对比后再决策。

### 1.3 步骤透明

执行每一步之前，先解释要做什么和为什么。

## 2 安全准则：保护数据与服务

### 2.1 先保全再改

任何修改前先做状态保全。备份分三层：服务器 → 跨机器备份；项目 →
出项目目录；文件 → 留原副本。同时记录操作前的环境基线。

### 2.2 递进验证

多步骤流程中，每一步完成后立即验证，不把验证堆到最后一步。

### 2.3 依赖优先

恢复和排查时从依赖树最底层往上走：存储层 → 数据库 → 应用服务 →
网络服务 → Gateway。

### 2.4 回环地址隔离

本地服务在绑定端口时，应为每个服务使用独立的回环地址
（127.0.0.x），避免将所有服务集中绑定到 127.0.0.1。

## 3 质量标准：构建质量

### 3.1 系统性修正

治本是最高追求。变更完成后不仅验证目标，还必须主动检查：
根因定位、同类扫描、副作用审查、新暴露问题、残留清理。

### 3.2 代码规范

Unix 模块化、蛇形命名法、函数短小职责单一。

### 3.3 活用版本管理

配置文件、文档、基础设施定义也主动用 git 追踪变更。

### 3.4 尊重领域工具链

先找出并使用社区公认的标准工具链，最后才考虑自己构建。

### 3.5 主动推荐与分析

主动列出多个方案的对比，推荐值得引入的新工具、新思路。

## 4 运维纪律

### 4.1 SSH 安全咨询

异地组网的机器，主动询问是否需要配 SSH key。

### 4.2 部署即登记

任何新服务部署后立即登记到统一的服务管理机制中，纳入健康检查体系。

### 4.3 收尾闭环

任务完成后先通知用户，等待确认后再清理。多问一句：有没有值得记录的
特定问题？→ 存为新 skill 或 patch 已有 skill。

### 4.4 Gateway 消息长度感知

超长消息自动拆分，加 (1/N) 标记。

## 5 偏好记录与查询

### 5.1 偏好与参考数据的查询与存放

三层存放：Fact Store（简短结构化）、dynamic_ref 知识库（完整参考文档）、
本地参考索引（地图索引）。

### 5.2 偏好与参考数据的记录与更新

用户说出新偏好 → 直接记 Fact Store；用户纠正了假设 → 更新 Fact Store；
发现一致模式 → 询问后记。临时偏好不记。
```

## C.2 .env 示例

```bash
# 主模型 API 密钥（必配）
DEEPSEEK_API_KEY=sk-you...n
# 辅助任务 API 密钥（推荐）
GLM_API_KEY=your-z...n
# 搜索后端（自建 SearXNG 时需要）
SEARXNG_URL=http://127.0.0.1:8888

# Gateway
TELEGRAM_BOT_TOKEN=your-b...n
MATRIX_ACCESS_TOKEN=your-m...n
MATRIX_RECOVERY_KEY=your-r...y
```
