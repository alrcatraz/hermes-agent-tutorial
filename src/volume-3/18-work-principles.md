\\newpage

# 第18章：工作原则 Skill 体系 {#ch:18}

!!! info "本章对应 Astra 生态组件"
    - `change-safeguard`（位于 `astra-aiagent-infra` 内）
    - `work-principles`（位于 `astra-aiagent-infra` 内）

[第6章](../volume-1/06-principles.md#ch:6) 定义了 SOUL 的宪法层原则（"做什么"）。
[第16章](16-agentic-harness.md) 介绍了 Agentic Harness Plugin 的强制执行框架（"必须怎么做"）。
本章介绍如何通过 Skill 体系**自动执行**具体的操作流程（"具体怎么做"）。

## 18.1 Skill 体系概览

### 18.1.1 什么是 Skill？

Skill 是 Hermes Agent 的 **可复用执行单元**——每个 Skill 封装了一个特定领域的操作流程、最佳实践、检查清单和避坑指南。当 Agent 遇到某个场景（如部署服务、修改文件、备份配置）时，通过 `skill_view()` 加载对应的 Skill，即可获得当前场景的**标准化操作指引**。

Skill 与传统文档的关键区别在于：

|          | 传统文档 | Hermes Skill |
|:---------|:---------|:-------------|
| **获取方式** | 用户主动搜索 | Agent 按需自动加载 |
| **更新方式** | 写时才改 | 用中发现坑即更新 |
| **粒度** | 章节/页面 | 场景化，精准对应任务 |

### 18.1.2 SOUL → Plugin → Skill 流水线

![SOUL → Plugin → Skill 流水线](../diagrams/principle-to-skill.svg){ width=35% }

SOUL 声明不可绕过的原则，Plugin 通过生命周期钩子**自动执行**（always-on），
Skill 通过按需加载提供**参考文档和操作流程**。

| 层级 | 作用 | 生效方式 |
|:-----|:-----|:---------|
| **SOUL.md** | 身份、语调、不可绕过原则 | 每次会话自动注入 |
| **Plugin** | HOOK 层：强制注入 + 状态跟踪 + 阻断违规 | 每轮 LLM 调用触发 |
| **Skill** | 执行层：任务分类路由、操作流程、检查清单 | 按场景按需加载 |

### 18.1.3 Skill 的加载与使用

Agent 在执行过程中通过以下方式加载 Skill：

1. **显式加载**：`skill_view(name)` — 加载并阅读 Skill 内容
2. **自动建议**：discipline 插件在检测到特定工具调用时自动推荐相关 Skill（见[第16章 §16.3.5](16-agentic-harness.md#sec:16.3.5)）
3. **手动调试**：通过 execution-framework 的建议推荐（见[§18.3](#sec:18.3)）

Skill 是"用中维护"的——当 Agent 发现文档步骤过时、命令失效或存在未覆盖的陷阱时，应立即通过 `skill_manage(action='patch')` 更新，使积累的经验持续沉淀。

## 18.2 Plugin 架构

Agentic Harness 的强制执行层由 discipline 和 context-anchor 两个 Plugin 实现。详见[第16章 Agentic Harness](16-agentic-harness.md) 和[第19章 Context Anchor](19-context-anchor.md)。

| Plugin | 职责 | 钩子 |
|:-------|:-----|:-----|
| **discipline** | 阶段状态机 + 工具拦截 | `pre_llm_call`、`pre_tool_call`、`post_tool_call` |
| **context-anchor** | 会话上下文锚定 | `pre_llm_call`、`post_tool_call` |

discipline 插件是 Agentic Harness 的执行纪律核心，通过五个阶段（`no_task` → `task_started` → `planning` → `executing` → `modifying` → `closing`）和对应的纪律门（Research Gate、Proposal Gate、Modify Gate、Closure Gate）确保 Agent 的行为受控。context-anchor 插件则在后台持续维护任务目标和关键事实，防止 Agent"跑偏"。

两个 Plugin 通过 `astra-aiagent-infra` meta-repo 统一部署。

## 18.3 执行框架（execution-framework） {#sec:18.3}

### 18.3.1 定位与现状

execution-framework 是一个**手动 keyword 技能推荐工具**，用于根据任务描述推荐应加载的 Skill 链。从 v2.0.1 起，它已从 Agentic Harness 中脱钩，不再被自动触发——Agentic Harness 的强制执行职责已由 discipline 插件接管（详见[第16章](16-agentic-harness.md)）。

如今 execution-framework 保留在生态中，供**手动调试和临时参考**使用。它在以下场景仍有价值：

- 想快速知道某个任务该用哪些 Skill
- 调试 routing 规则是否匹配到位
- 在不开启 discipline 插件的环境中使用

### 18.3.2 使用方法

execution-framework 提供三种调用模式：

```bash
# 标准输出模式 — 获取某个任务对应的技能建议
python3 scripts/recommend.py "帮我把 Nginx 配置成反向代理"

# JSON 输出模式 — 可编程使用
python3 scripts/recommend.py --json "push this repo to GitHub"

# 交互模式 — 逐步引导
python3 scripts/recommend.py --interactive
```

### 18.3.3 路由机制

execution-framework 通过 `routing.yaml` 路由表匹配任务关键词，输出对应的 Skill 链推荐：

```yaml
# routing.yaml 片段（示意）
rules:
  - keywords: ["nginx", "反向代理", "proxy"]
    skills: ["deploy-register", "server-health-audit"]
  - keywords: ["git", "push", "commit", "PR"]
    skills: ["astra-vcs-assist-git-sync"]
  - keywords: ["install", "部署", "deploy", "setup"]
    skills: ["pre-action-research", "deploy-register"]
```

Agent 在收到推荐后，使用 `skill_view()` 手动加载对应的 Skill。

### 18.3.4 相关资源

- 仓库：[`astra-skill-execution-framework`](https://github.com/alrcatraz/astra-skill-execution-framework)
- 当前推荐路径：discipline 插件的自动 Skill 建议（[§16.3.5](16-agentic-harness.md#sec:16.3.5)）

## 18.4 各 Skill 职责

### pre-action-research

动手前完成信息收集。检查清单：信息类型 → 查索引、文档 → 提方案 → 等批准。

适用于任何不确定操作步骤或需要先了解环境的场景。强制 Agent 在 `web_search`、`web_extract`、`read_file` 等调研工具上完成充分的信息收集，再提出执行计划。

### change-safeguard

修改前强制保全。三层备份（跨机器 / git commit / .bak）+ 环境基线记录。

当 Agent 进入 `modifying` 阶段时，discipline 插件的 Modify Gate 会建议加载此 Skill。适用于所有修改性操作——配置文件、代码、数据等。

### deploy-register

新服务部署后立即登记到服务清单，防止"管理黑洞"。

记录的内容包括：服务名、IP/端口、部署路径、部署时间、依赖组件、维护者。确保每新增一个服务，基础设施清单就更新一次。

### work-closure-check

任务结束时七阶段检查：凭证扫描 → skill 更新 → 决策记录 → 登记检查 → 信息存储 → 基线对比 → 提交整理。

Closure Gate 激活时自动注入此 Skill 的完整检查清单。确保每个任务都有明确的关闭流程，不会遗留 SSH 连接、临时代码或未记录的决策。

## 18.5 安装 {#sec:18.5}

所有 work-principles 体系的组件（Plugin + Skill）通过 `astra-aiagent-infra` meta-repo 统一部署。

### 目录结构

| 位置 | 用途 |
|:-----|:------|
| `~/Projects/astra/astra-aiagent-infra/` | dev copy（git-tracked，可 push GitHub） |
| `~/.astra/repos/astra-aiagent-infra/` | private copy（symlink 目标，Hermes 运行时加载） |
| `~/.hermes/skills/devops/<name>/` | symlink → private copy |
| `~/.hermes/plugins/<name>/` | symlink → private copy |

### 安装步骤

```bash
# 1. 部署 meta-repo（如果尚未部署）和 execution-framework
#    dev copy 在 ~/Projects/astra/ 下手动创建或 clone
#    private copy 从 GitHub clone（或从 dev copy 本地 clone）
git clone https://github.com/alrcatraz/astra-aiagent-infra.git \
  ~/.astra/repos/astra-aiagent-infra
git clone https://github.com/alrcatraz/astra-skill-execution-framework.git \
  ~/.astra/repos/astra-skill-execution-framework

# 2. 运行 lifecycle-sync — 自动注入 LIFECYCLE_HOOKS 标记到 skill docs
cd ~/.astra/repos/astra-aiagent-infra
python3 lifecycle/astra-lifecycle-sync.py --update

# 3. 创建 symlink 桥接 — Skills
ln -sfn ~/.astra/repos/astra-aiagent-infra/work-principles/skills/astra-skill-work-principles \
  ~/.hermes/skills/devops/work-principles
ln -sfn ~/.astra/repos/astra-aiagent-infra/work-principles/skills/pre-action-research \
  ~/.hermes/skills/devops/pre-action-research
ln -sfn ~/.astra/repos/astra-aiagent-infra/work-principles/skills/deploy-register \
  ~/.hermes/skills/devops/deploy-register
ln -sfn ~/.astra/repos/astra-aiagent-infra/work-principles/skills/work-closure-check \
  ~/.hermes/skills/devops/work-closure-check
ln -sfn ~/.astra/repos/astra-skill-execution-framework \
  ~/.hermes/skills/devops/execution-framework

# 4. 创建 symlink 桥接 — Plugins
ln -sfn ~/.astra/repos/astra-aiagent-infra/work-principles/plugin/discipline \
  ~/.hermes/plugins/work-principles
ln -sfn ~/.astra/repos/astra-aiagent-infra/work-principles/plugin/context-anchor \
  ~/.hermes/plugins/context-anchor

# 5. 创建 symlink 桥接 — change-safeguard（已合并到 work-principles）
ln -sfn ~/.astra/repos/astra-aiagent-infra/work-principles/skills/change-safeguard \
  ~/.hermes/skills/devops/change-safeguard

# 6. 启用插件（需重启 session 生效）
hermes plugins enable work-principles --allow-tool-override
hermes plugins enable context-anchor
```

### 验证

```bash
# 验证插件状态
hermes plugins list
# 应输出类似：
#   work-principles    enabled     pre_llm_call, pre_tool_call, post_tool_call
#   context-anchor     enabled     pre_llm_call, post_tool_call

# 验证 Skill 加载
# 重启 session（/new）后，加载任意 skill 测试
skill_view(name='work-principles')
```

---
