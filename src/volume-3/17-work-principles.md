# 第17章：工作原则 Plugin 和 Skill 体系 {#ch:17}

!!! info "本章对应 Astra 生态组件"
    - [`execution-framework`](https://github.com/alrcatraz/astra-skill-execution-framework)
    - [`change-safeguard`](https://github.com/alrcatraz/astra-skill-change-safeguard)
    - `work-principles`（位于 `astra-aiagent-infra` 内）

## 从 SOUL 到 Skill

[第6章](../volume-1/06-principles.md) 定义了 SOUL 的宪法层原则（"做什么"）。
本章介绍如何通过 Plugin 和 Skill 体系**自动执行**这些原则（"怎么做"）。

## 架构概览

![SOUL → Plugin → Skill 流水线](../diagrams/principle-to-skill.svg)

SOUL 声明不可绕过的原则，Plugin 通过生命周期钩子**自动执行**（always-on），
Skill 通过按需加载提供**参考文档和操作流程**。

| 层级 | 作用 | 生效方式 |
|:-----|:-----|:---------|
| **SOUL.md** | 身份、语调、不可绕过原则 | 每次会话自动注入 |
| **Plugin** | HOOK 层：强制注入 + 状态跟踪 + 阻断违规 | 每轮 LLM 调用触发 |
| **Skill** | 执行层：任务分类路由、操作流程、检查清单 | 按场景按需加载 |

## 执行框架（execution-framework）

统一调度中心。收到任务后先路由到对应 skill。

| 任务类型 | 路由目标 | 对应原则 |
|:---------|:---------|:---------|
| 研究/方案 | pre-action-research | §1 研究先行 |
| 修改系统 | change-safeguard | §4 先保全再改 |
| 部署服务 | deploy-register | §4.2 部署登记 |
| 收尾闭环 | work-closure-check | 收尾检查 |

## Plugin 架构（强制执行层）

work-principles 的 Plugin 系统位于 `astra-aiagent-infra/work-principles/plugin/`，包含两个协同工作的插件：

| 插件 | 目录 | 职责 |
|:-----|:-----|:-----|
| **discipline** | `plugin/discipline/` | 阶段状态机（phase state machine）。`pre_llm_call` 注入阶段指引，`pre_tool_call` 拦截违规操作，`post_tool_call` 自动检测阶段转换。Agent 通过 `discipline_set_phase()` 声明阶段切换 |
| **context-anchor** | `plugin/context-anchor/` | 会话上下文维护。自动注入 `[AGENT CONTEXT]` 头部（当前主机、任务、线程历史），`post_tool_call` 自动检测 SSH 跳转和任务变更 |

### 为什么需要 Plugin？

Skills 是**按需加载**的（依赖系统提示词的 relevance matching），无法保证 Agent 在每轮对话中都主动加载。Plugin 的 lifecycle hooks（`pre_llm_call`、`pre_tool_call`、`post_tool_call`、`on_session_start`）在**每轮 LLM 调用**时触发，不依赖 Agent 的"记忆"，从架构层面确保原则被执行。

### lifecycle-sync 与 LIFECYCLE_HOOKS

`astra-lifecycle-sync` 是 `astra-aiagent-infra/lifecycle/` 下的同步工具。它读取 `registry.yaml` 中各组件声明的 lifecycle hooks，然后通过 `<!-- LIFECYCLE_HOOKS_BEGIN -->` / `<!-- LIFECYCLE_HOOKS_END -->` 标记注入到对应的 SKILL.md 文件中：

![lifecycle-sync 标记注入流程](../diagrams/lifecycle-sync-hooks.svg)

这样，deploy-register 和 work-closure-check 的检查清单可以**从 registry 声明自动生成**，而非手动维护。运行 `python3 lifecycle/astra-lifecycle-sync.py --update` 即可同步。

### 部署管线

Plugin 和 Skill 的完整部署遵循"清洁 dev → 同步 → 私密运行时"原则：

![Lifecycle-Sync 部署管线](../diagrams/lifecycle-sync.svg)

核心原则：**dev copy 是干净的 git 工作树（可 push 到公开 GitHub），private copy 是运行时加载的目标（symlink 指向这里）。dev copy 中的修改通过 git push/pull 流向 private copy，再由 `lifecycle-sync` 确保 hooks 标记是最新的。**

## 各 Skill 职责

### pre-action-research
动手前完成信息收集。检查清单：信息类型 → 查索引、文档 → 提方案 → 等批准。

### change-safeguard
修改前强制保全。三层备份（跨机器 / git commit / .bak）+ 环境基线记录。

### deploy-register
新服务部署后立即登记到服务清单，防止"管理黑洞"。

### work-closure-check
任务结束时七阶段检查：凭证扫描 → skill 更新 → 决策记录 → 登记检查 → 信息存储 → 基线对比 → 提交整理。

## 安装

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

### 日常同步

dev copy 修改后，同步到 private copy：

```bash
cd ~/Projects/astra/astra-aiagent-infra
git push origin main                # push dev → GitHub
cd ~/.astra/repos/astra-aiagent-infra
git pull origin main                # pull GitHub → private
python3 lifecycle/astra-lifecycle-sync.py --update   # 刷新 LIFECYCLE_HOOKS
```

---
