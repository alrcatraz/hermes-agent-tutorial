# 第16章：知识库与信息分级储存 {#ch:16}

!!! info "本章对应 Astra 生态组件"
    - [`astra-knowledge-base-mcp`](https://github.com/alrcatraz/astra-knowledge-base-mcp) — MCP 知识库服务
    - [`astra-aiagent-infra`](https://github.com/alrcatraz/astra-aiagent-infra) — 生态门户

## 16.1 为什么需要知识库？

随着 Hermes Agent 积累的技能、配置、偏好越来越多，如何高效地组织和检索信息成为一个关键问题。Hermes 提供了多层记忆系统，但 **知识库（Knowledge Base）** 是专门为长期、结构化信息设计的存储方案。

### 三种独立存储机制

Hermes 提供三种**独立互补**的存储机制——各司其职，而非层级关系：

| 存储机制 | 存储内容 | 示例 | 访问方式 |
|:--------|:--------|:----|:--------|
| **Memory（记忆）** | 用户偏好、简短事实 | 语言偏好、常用路径 | 自动注入上下文 |
| **Skill（技能）** | 流程性知识、工作流 | 操作步骤、命令模板 | 按场景触发加载 |
| **Knowledge Base MCP（知识库）** | 结构化长期信息 | 设备清单、事故记录、参考文档 | MCP 查询工具 |

## 16.2 MCP 知识库服务器

Astra 生态的 `astra-knowledge-base-mcp` 知识库服务使用 **PostgreSQL 16 + pgvector 0.8** 作为后端存储，通过 MCP 协议向 Hermes 暴露工具接口。

### 后端架构

与原来的 SQLite + FTS5 方案不同，新版后端采用 PostgreSQL 的原生全文搜索（`tsvector`）配合 pgvector 向量索引，实现了三种搜索模式：

| 搜索模式 | 实现 | 适用场景 |
|:--------|:-----|:---------|
| **fts** | PostgreSQL `tsvector` + GIN 索引 | 精确关键词匹配，适合故障代码、IP 地址、命令名 |
| **vector** | pgvector `hnsw` 索引 + 余弦相似度 | 语义搜索，适合自然语言描述的症状、概念 |
| **hybrid**（默认） | FTS + vector 融合排序 | 综合场景，兼具精确匹配和语义理解 |

**数据隔离：** 每个知识库对应一个独立的 PostgreSQL schema（`kb_<name>`），各 schema 下的 `chunks` 表结构相同但物理隔离，删除知识库只需 `DROP SCHEMA … CASCADE`，干净彻底。

### 安装

```bash
# 克隆仓库
git clone https://github.com/alrcatraz/astra-knowledge-base-mcp.git
cd astra-knowledge-base-mcp

# 安装依赖
uv sync
```

### 前提条件

```bash
# PostgreSQL 16 + pgvector 扩展
sudo zypper install postgresql16-server postgresql16-contrib
# 或通过源码安装 pgvector 0.8.2+

# 创建数据库并启用扩展
sudo -u postgres createdb astra_kb
sudo -u postgres psql -d astra_kb -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### 配置到 Hermes

在 `config.yaml` 的 `mcp_servers` 段添加：

```yaml
mcp_servers:
  astra-knowledge-base:
    command: /path/to/astra-knowledge-base-mcp/run.sh
    enabled: true
    env:
      ASTRA_KB_BACKEND: postgres
```

环境变量说明：

| 变量 | 默认值 | 说明 |
|:-----|:-------|:-----|
| `ASTRA_KB_BACKEND` | `postgres` | 后端类型（`postgres` / `sqlite`） |
| `ASTRA_KB_PG_DSN` | `dbname=astra_kb user=postgres host=/run/postgresql` | PostgreSQL 连接串 |
| `ASTRA_EMBED_BACKEND` | `local` | 嵌入后端（`siliconflow` / `local`） |
| `ASTRA_EMBED_API_KEY` | - | 嵌入 API 密钥（替代 `SILICONFLOW_API_KEY`，向后兼容） |
| `ASTRA_EMBED_API_URL` | - | 嵌入 API 端点（OpenAI 兼容 `/v1/embeddings`） |
| `ASTRA_EMBED_MODEL` | `Qwen/Qwen3-Embedding-8B` | 嵌入模型名称 |
| `ASTRA_EMBED_DIM` | `1024` | 嵌入向量维度 |

## 16.3 实战：信息分级存储策略

通过合理划分知识库，可以实现信息的分级管理与快速检索。

!!! tip "设计原则"
    将**不变信息**（设备规格、凭证索引）与**变化信息**（事故记录、运行日志）分开存储，便于定期清理和更新。

---

## 16.4 建库策略与实战

Astra 生态中的 `astra-knowledge-base-mcp` 已部署并在线，维护以下知识库：

| 知识库 | 用途 | 更新方式 |
|:-------|:-----|:---------|
| `dynamic_ref` | 会变的参考数据（Gateway 消息长度、Provider API、工具坑） | cron 定期刷新 |
| `hermes_config` | Hermes 附加配置（外挂服务/MCP/CLI 工具/端口/路径） | 部署时手动更新 |
| `service_mgmt` | 管理方案（健康检查/维护日志/事件记录） | 运行时自动写入 |
| `sre_incidents` | SRE 事故记录（根因分析、诊断过程、修复经验） | 每次事故后记录 |

### 16.4.1 PostgreSQL + pgvector 后端

该 MCP 知识库服务使用 **PostgreSQL 16 + pgvector 0.8.2** 作为后端，每个知识库对应一个独立的 PostgreSQL schema，每张 `chunks` 表同时承载全文索引和向量索引：

-   **全文搜索：** `search_vec TSVECTOR` 列，由 `title` 和 `content` 自动生成（`GENERATED ALWAYS AS`），使用 GIN 索引加速
-   **向量搜索：** `embed_vec vector(1024)` 列，使用 HNSW 索引（`vector_cosine_ops`），支持余弦相似度排序
-   **混合搜索：** 分别执行 FTS 和向量搜索，按加权融合分数合并排序（默认权重各 50%）

![PostgreSQL 知识库架构](../diagrams/kb-pg-structure.svg)

每 KB 的 `chunks` 表结构：

```sql
CREATE TABLE kb_<name>.chunks (
    id         SERIAL PRIMARY KEY,
    title      TEXT NOT NULL DEFAULT '',
    content    TEXT NOT NULL,
    source     TEXT,
    tags       TEXT[] DEFAULT '{}',
    media_url  TEXT,
    media_type TEXT,
    embed_vec  vector(1024),                              -- ← pgvector 列
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    search_vec TSVECTOR GENERATED ALWAYS AS (             -- ← 自动全文索引
        to_tsvector('simple', coalesce(title,'') || ' ' || content)
    ) STORED
);

CREATE INDEX idx_<name>_fts ON kb_<name>.chunks USING gin(search_vec);
CREATE INDEX idx_<name>_embed ON kb_<name>.chunks USING hnsw (embed_vec vector_cosine_ops);
```

MCP 工具接口保持一致，并新增 `search_mode` 参数：

| 工具 | 功能 |
|:-----|:-----|
| `kb_list()` | 列出所有 KB，含启用/禁用状态 |
| `kb_create(name, description)` | 创建新知识库（自动建 schema + 表） |
| `kb_delete(name)` | 删除知识库（`DROP SCHEMA … CASCADE`） |
| `kb_enable(name)` / `kb_disable(name)` | 按需开关特定 KB |
| `kb_add(kb, content, title, source, tags)` | 添加知识条目（自动分块 + 嵌入向量） |
| `kb_search(query, kb_names, limit, search_mode)` | 跨 KB 搜索，`search_mode` 支持 `hybrid` / `fts` / `vector` |
| `kb_list_chunks(kb, limit, offset)` | 分页浏览知识库内容 |
| `kb_update(kb, chunk_id, ...)` | 更新条目（支持 `replace` / `append` 模式） |
| `kb_delete_chunk(kb, chunk_id)` | 删除单条记录 |

### 16.4.2 信息分级存储决策树

面对一条新信息时，如何决定它该存到哪里？以下是 Astra 实战中形成的决策树：

![信息分级存储决策树](../diagrams/kb-decision-tree.svg)


### 16.4.3 标签与搜索实战

为知识条目打标签是小投入高回报的做法。以下来自 `sre_incidents` 知识库的示例：

```python
# 添加事故记录（带标签）
kb_add(
    kb="sre_incidents",
    title="E2EE Stale OTK 修复",
    content="根因：Panic 重启导致 OTK 计数归零...",
    tags=["e2ee", "otk", "gateway", "repair"]
)

# 按标签分类搜索
kb_search("OTK 同步失败", kb_names=["sre_incidents"])
```

标签建议：

- **领域标签**：`mcp`, `credential`, `gateway`
- **操作标签**：`repair`, `diagnosis`, `config`, `deploy`
- **严重级别标签**：`p1`, `p2`, `p3`

### 16.4.4 MCP 知识库配置到 Hermes

在 `~/.hermes/config.yaml` 的 `mcp_servers` 段配置 MCP 知识库服务：

```yaml
mcp_servers:
  astra-knowledge-base:
    command: /home/user/.astra/repos/astra-knowledge-base-mcp/run.sh
    enabled: true
    env:
      ASTRA_KB_BACKEND: postgres
```

!!! tip "环境变量按需配置"
    大多数情况下只需 `ASTRA_KB_BACKEND: postgres`。如果 PostgreSQL 不在默认位置，设置 `ASTRA_KB_PG_DSN`；如果使用 SiliconFlow 嵌入（而非本地 llama.cpp），设置 `ASTRA_EMBED_BACKEND: siliconflow` 和 `SILICONFLOW_API_KEY`。

配置后，Hermes Agent 在会话中即可通过 `kb_search()` 查询知识库，无需每次手动打开文件或翻阅 skill 目录。默认使用 **hybrid 混合搜索**，同时匹配关键词和语义相似度。如需精确匹配，可指定 `search_mode: "fts"`；如查询自然语言描述，可指定 `search_mode: "vector"`。

!!! tip "搜索优先原则"
    在诊断新故障之前，**总是**先 `kb_search("sre_incidents", <症状>)`。很多问题之前已经被解决过。知识库是故障排查的“第一枪”。

---
