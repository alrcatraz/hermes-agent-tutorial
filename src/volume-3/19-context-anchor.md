\\newpage

# 第19章：上下文锚定 — 帮助 Hermes Agent 保持认知连续 {#ch:19}

!!! info "本章对应 Astra 生态组件"
    - `context-anchor`（位于 `astra-aiagent-infra/work-principles/plugin/context-anchor/`）

## 19.1 问题：长会话中的认知错乱

Hermes Agent 的每一次交互都是无状态的——LLM 本身不记得上一轮对话的内容，全靠 Hermes 框架在每轮调用前将完整的对话历史和系统提示词重新注入。这带来两个问题：

**问题一：会话漂移（Session Drift）。** 随着对话增长，上下文窗口逐渐被填满。当窗口满时，最早的消息被截断，Agent 丧失了"一开始我想做什么"的全局认知。在多轮工具调用后，这种渐行渐远的现象越来越明显。

**问题二：断开即失忆（Disconnect Amnesia）。** 通过 SSH 连接到远程主机时，每次连接都是一个全新的会话。Agent 不知道当前的 session_id，不知道当前正在执行的任务，也无法利用此前在相同主机上的执行记录。每次 SSH 都要重新建立认知。

Context Anchor 通过 SSH `SendEnv` / `AcceptEnv` 机制，在连接建立时自动注入上下文标头，解决这两个问题。

## 19.2 架构总览

![Context Anchor 架构](../diagrams/context-anchor.svg){ width=30% }

**图 19.2-1**: Context Anchor 架构图

### 双后端设计

Context Anchor 支持两种存储后端，配置即切换：

| 后端 | 说明 |
|:-----|:------|
| SQLite（默认） | 单机使用，零配置 |
| PostgreSQL | 多设备、多 profile 共享状态 |

SQLite 模式写入 `~/.hermes/persistent/context-anchor.db`，使用 WAL 模式 + `synchronous=NORMAL` 保证写入安全。PG 模式可复用 Astra 知识库的同一 PostgreSQL 实例——如果用户已部署 Astra KB（见[第17章](17-knowledge-base.md)），Context Anchor 无需额外配置。

### 三字段追踪

每次会话记录三个关键字段的追踪数据：

| 字段 | 说明 |
|:-----|:------|
| **Host** | 当前主机名，自动从环境变量读取 |
| **Task** | 当前任务上下文，从会话主题推断 |
| **Thread** | 会话线程 ID 链，追踪历史会话 |

这三个字段组成 `[AGENT CONTEXT]` 标头，在每次 LLM 调用前自动注入系统提示词：

```
[AGENT CONTEXT]
host=HomeCentre01
task=network-maintenance
[THREAD HISTORY]
3 sessions
```

Context Anchor 在 Hermes 生命周期钩子中工作：
- **pre_llm_call** — 读取 state.json → 注入标头
- **post_tool_call** — 记录 session_id → 推断 task → 检测 SSH

## 19.3 后端架构：双数据库支持

### 19.3.1 存储后端对比

| 特性 | SQLite（默认） | PostgreSQL |
|:-----|:--------------|:-----------|
| 配置 | SQLite 零配置开箱即用；PG 可在已部署 Astra KB 时零配置复用 | 需设置 `database_url` 连接至 PostgreSQL 实例 |
| 依赖 | Python stdlib `sqlite3` | 需安装 `psycopg2` |
| 写安全 | WAL 模式 + `synchronous=NORMAL` | 原生事务支持 |
| 适用场景 | 单机开发/轻量使用 | 多设备、多 profile 共享状态 |

### 19.3.2 启用插件

在 `~/.hermes/plugins.yaml` 中配置：

```yaml
plugins:
  - name: context-anchor
    enabled: true
    config:
      backend: sqlite  # 或 postgresql
      auto_inject: true
```

## 19.4 全工具追踪

Context Anchor 追踪**所有** Hermes 工具的状态，而非仅限于终端命令：

| 工具 | 追踪内容 |
|:----|:---------|
| `browser_navigate` | 记录当前 URL、页面标题 |
| `terminal` | 记录最近执行的工作目录、命令 |
| `web_extract` | 记录提取源 URL |
| `read_file` / `write_file` / `patch` | 记录文件路径 |

这使得 SSH 跳转后，Agent 仍然知道原始端发生了什么工具操作——即使跳转前的工作目录、提取结果不在新会话中直接可用，标头中的摘要信息足以保持上下文连续性。

## 19.5 安装与启用

### 目录结构

```
~/.hermes/plugins/context-anchor/
├── __init__.py
├── plugin.py
├── context_anchor.py
├── state_manager.py
└── README.md
```

该 plugin 位于 `astra-aiagent-infra/work-principles/plugin/context-anchor/`，通过 Hermes Plugin 机制映射到 `~/.hermes/plugins/`。

### 安装步骤

1. 确认 `astra-aiagent-infra` 已克隆：
   ```bash
   ls ~/.astra/repos/astra-aiagent-infra/work-principles/plugin/context-anchor/
   ```

2. 确保 `plugins.yaml` 启用了 `context-anchor`：
   ```bash
   hermes plugins list | grep context-anchor
   ```
   如未启用，参考 19.3.2 添加配置。

3. 重启 Hermes：
   ```bash
   /restart
   ```

4. 验证：
   ```bash
   hermes plugins list
   ```
   输出应包含 `context-anchor`，状态为 `✅ enabled`。

### SSH 服务端配置

在远程主机的 `/etc/ssh/sshd_config` 中允许传递环境变量：

```
AcceptEnv X-Hermes-Session-Id X-Hermes-Task X-Hermes-Host
```

在客户端 `~/.ssh/config` 中启用发送：

```
Host *
    SendEnv X-Hermes-*
```

## 19.6 实战效果

启用 Context Anchor 后，SSH 到远程主机的体验：

| 场景 | 有 Context Anchor | 无 Context Anchor |
|:----|:-----------------|:------------------|
| SSH 到服务器 | Agent 自动知道在哪个主机、为什么上来 | Agent 需要手动确认 |
| 多会话管道 | Agent 能追踪前序会话的执行结果 | 每轮都是全新开始 |
| 跨主机迁移 | Agent 了解完整上下文链 | 需要手动提供全部背景 |

---

