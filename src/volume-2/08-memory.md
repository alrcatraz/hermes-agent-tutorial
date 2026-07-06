# 第8章：外部记忆系统配置 {#ch:8}

Hermes Agent 支持八种外部记忆提供者（Memory Provider），从轻量键值存储到支持代数推理的深度记忆引擎。本章首先介绍全部八种提供者，再推荐默认选项 Holographic Memory，并给出管理建议。

## 8.1 记忆提供者概览

在 Hermes 中，“记忆”不仅仅是保存一段文本——不同场景需要不同的记忆策略。Hermes 支持以下八种外部记忆提供者，可在 `config.yaml` 中通过 `memory.provider` 切换：

| 提供者 | 类型 | 部署方式 | 核心特点 | 适用场景 |
|:-----|:-----|:--------|:---------|:---------|
| **Holographic** | 内置引擎 | 零配置 | 实体-关系图 + 信任评分 + 代数推理 | **推荐默认**，深度结构化记忆 |
| **Honcho** | 外部服务 | API / 自托管 | 用户记忆管理平台，支持对话衍生记忆 | 跨会话用户画像管理 |
| **OpenViking** | 外部服务 | 自托管 | 开源记忆提供者，社区驱动 | 自托管记忆需求 |
| **Mem0** | 外部服务 | API / 自托管 | 图结构记忆层，分层召回与语义搜索 | AI Agent 记忆中间件 |
| **Hindsight** | 外部服务 | API / 自托管 | 时间序列记忆，事件时间线与上下文窗口 | 时间敏感的长会话记忆 |
| **RetainDB** | 外部服务 | 自托管 | 持久化键值存储，简洁 API | 简单持久化记忆需求 |
| **ByteRover** | 外部服务 | API / 自托管 | 云端记忆服务，自动摘要与检索 | 分布式/云端记忆系统 |
| **Supermemory** | 外部服务 | API | 多源记忆聚合，跨平台整合 | 多平台、多 Agent 记忆共享 |

### 8.1.1 Holographic Memory（内置推荐引擎）

Holographic Memory 是 Hermes 内置的深度记忆引擎，支持**实体解析、信任评分和代数推理**。它不把事实当作孤立的字符串，而是构建实体关系图，支持跨实体的组合查询与矛盾检测。**零配置，开箱即用**，是 Hermes 默认推荐的记忆方案。

```yaml
memory:
  provider: holographic
  memory_enabled: true
  memory_char_limit: 4000
```

详见 [§8.2](#sec:8-2)。

### 8.1.2 Honcho

Honcho 是一个用户记忆管理平台，专为 AI 对话场景设计。它从对话中自动衍生用户记忆（derived memories），支持会话隔离和用户画像构建。适合需要跨会话追踪用户偏好的场景。

```yaml
memory:
  provider: honcho
  honcho_api_url: "https://your-honcho-instance.com"
  honcho_app_id: "your-app-id"
  honcho_user_id: "your-user-id"
```

**特点：**

- 自动从对话中提取并衍生记忆
- 支持多用户隔离
- 可自托管或使用云服务

### 8.1.3 OpenViking

OpenViking 是一个开源的外部记忆提供者，由社区维护。适合希望完全掌控记忆基础设施的团队。

```yaml
memory:
  provider: openviking
  openviking_url: "http://localhost:8080"
```

**特点：**

- 完全开源、可审计
- 自托管部署
- 社区驱动开发

### 8.1.4 Mem0

Mem0 是专为 AI Agent 设计的记忆层，提供图结构记忆存储和分层召回能力。支持语义搜索和记忆优先级管理。

```yaml
memory:
  provider: mem0
  mem0_api_key: "${MEM0_API_KEY}"
```

**特点：**

- 图结构记忆，支持关联推理
- 语义搜索与分层召回
- 适合生产环境 Agent 记忆中间件

### 8.1.5 Hindsight

Hindsight 专注于时间序列记忆，以事件时间线的形式组织信息。适合需要追溯历史上下文的长会话场景。

```yaml
memory:
  provider: hindsight
  hindsight_api_key: "${HINDSIGHT_API_KEY}"
```

**特点：**

- 时间线组织记忆
- 上下文窗口管理
- 适合长期运行的 Agent 会话

### 8.1.6 RetainDB

RetainDB 提供轻量的持久化键值存储，API 简洁。适合不需要复杂推理、仅需持久化保存简单事实的场景。

```yaml
memory:
  provider: retaindb
  retaindb_url: "http://localhost:8000"
```

**特点：**

- 极简 API，类似 Redis
- 自托管，轻量部署
- 适合简单持久化需求

### 8.1.7 ByteRover

ByteRover 是云端记忆服务，提供自动摘要和智能检索能力。适合分布式系统和云端部署场景。

```yaml
memory:
  provider: byterover
  byterover_api_key: "${BYTEROVER_API_KEY}"
```

**特点：**

- 云端托管，免运维
- 自动摘要生成
- 智能检索与去重

### 8.1.8 Supermemory

Supermemory 支持多源记忆聚合，可整合来自不同平台和 Agent 的记忆数据。适合多 Agent 协作和跨平台记忆共享。

```yaml
memory:
  provider: supermemory
  supermemory_api_key: "${SUPERMEMORY_API_KEY}"
```

**特点：**

- 多源记忆聚合
- 跨 Agent / 跨平台共享
- 统一记忆接口

!!! info "选择指南"
    - 零配置开箱即用 → **Holographic**（推荐默认）
    - 自托管记忆 → Honcho、OpenViking、RetainDB
    - 图结构 / 语义搜索 → Mem0
    - 时间线 / 长会话 → Hindsight
    - 云端免运维 → ByteRover
    - 多 Agent 共享 → Supermemory

## 8.2 Holographic Memory（推荐默认方案） {#sec:8-2}

Holographic Memory 是 Hermes 推荐的外部记忆方案。它基于实体-关系模型，为每个事实附加实体标签和信任评分，支持代数级别的组合推理。

### 配置

```yaml
memory:
  memory_enabled: true
  user_profile_enabled: true
  memory_char_limit: 4000   # 记忆字符上限
  user_char_limit: 2500    # 用户画像字符上限
  provider: holographic    # 记忆引擎
  nudge_interval: 10       # 主动存储提示间隔（轮次）
```

### 常用操作

`fact_store` 工具支持五种查询模式：

| 操作 | 用途 | 示例 |
|:-----|:-----|:-----|
| `add` | 存储事实 | 用户偏好、项目约定 |
| `search` | 关键词查找 | `'editor config'`, `'deploy process'` |
| `probe` | 实体召回 | 某个人的所有相关事实 |
| `reason` | 组合查询 | 多个实体间的关联推理 |
| `contradict` | 发现矛盾 | 找出冲突的旧事实 |

**使用场景：**

```bash
# 存储：用户偏好
fact_store action=add content="用户 prefers official/maintained solutions" category=user_pref

# 召回：关于某个项目的所有事实
fact_store action=probe entity="SearXNG"

# 交叉推理
fact_store action=reason entities="Hermes Agent, memory"
```

`fact_feedback` 工具用于训练记忆质量：

```bash
# 标记有帮助的事实
fact_feedback action=helpful fact_id=42
# 标记过时的事实
fact_feedback action=unhelpful fact_id=7
```

### 与其他记忆提供者的选择

Holographic 是推荐默认方案，但不同场景适合不同提供者：

| 场景 | 推荐提供者 | 说明 |
|:-----|:----------|:-----|
| 零配置开箱即用 | `holographic` | 内置引擎，无需外部依赖 |
| 简单键值持久化 | `retaindb` | 极简 API，类似 Redis |
| 图结构 / 语义搜索 | `mem0` | 分层召回，关联推理 |
| 时间线 / 长会话 | `hindsight` | 事件时间线组织 |
| 云端免运维 | `byterover` | 托管服务，自动摘要 |
| 多 Agent 共享 | `supermemory` | 多源记忆聚合 |
| 自托管 + 用户画像 | `honcho` | 对话衍生记忆 |

!!! tip "技巧"
    不要用 `fact_store` 保存任务进度或临时 TODO，这些应该用 `session_search` 回溯。事实应当是对未来会话有用的**持久性知识**。

## 8.3 记忆存储插件

Hermes 内置的 `hermes-memory-store` 插件自动将静态事实
（如 SOUL.md 中的工作原则）提取到记忆系统中：

```yaml
plugins:
  hermes-memory-store:
    auto_extract: true
```

启用后，Hermes 会在启动时自动扫描关键配置中的事实并注入到记忆中，
无需手动 `fact_store action=add`。

**工作原理：**

1. 插件在 Hermes 启动时加载
2. 扫描 `SOUL.md`、用户画像、项目配置等关键文件
3. 提取其中声明的原则、偏好、约束等静态事实
4. 自动调用 `fact_store` 注入到 Holographic Memory 中

这使得核心原则（如“优先使用官方方案”、“代码需通过 lint 检查”等）无需每次手动存储，Agent 启动后即可感知。

## 8.4 记忆管理建议

- **选择合适提供者**：零配置选 Holographic，简单持久化选 RetainDB，语义搜索选 Mem0，时间线选 Hindsight（参见上表）
- **定期回顾**：`session_search()` 检查最近会话，判断哪些事实值得保存
- **信任训练**：使用 `fact_feedback` 标记有用/无用的记忆，系统会自动调优信任评分
- **避免污染**：不要向记忆系统灌入临时任务进度或一次性信息；这些用会话历史即可回溯
- **技能 vs 记忆**：复杂工作流应存为 **Skills**（`skill_manage`），实体关系存为 **fact_store**，简单偏好通过 Holographic 自动管理
- **外部提供者维护**：使用外部提供者（Honcho、Mem0 等）时，定期检查 API 可用性和数据一致性

---
