# 第十四章：Astra Hub——生态门户 {#ch:14}


!!! info "关于 Astra 生态"
    本书开卷已对 Astra 生态做了总览。本章详细介绍生态门户——Astra Hub（`astra-aiagent-infra`）——作为统一索引、注册表和模板引擎的具体实现。它不包含业务逻辑，而是扮演三个角色：

- **生态地图**：索引所有 astra-* 项目的位置、用途和关系
- **技能注册表**：通过 `registry.yaml` 统一管理所有技能的版本和路径
- **模板引擎**：提供项目模板和生命周期钩子，保证新组件的一致开局

## 14.1 为什么需要门户？

随着 Astra 生态从几个组件扩展到十几个，各个项目变得分散。Astra Hub 解决三个问题：

| 问题 | 解决方案 |
|:-----|:---------|
| "这个项目放哪儿？" | 统一的项目索引表 |
| "我的技能是最新版吗？" | registry.yaml 版本管理 |
| "新项目怎么起手？" | 模板库 + 生命周期钩子 |

### 公开/私有分离

所有 astra-* 项目采用双重布局，区分可公开推送 GitHub 的代码和个人数据：

| 路径 | 内容 | 用途 |
|:----|:------|:------|
| `~/astra/<repo>/` | 公开代码 | 推送到 GitHub |
| `~/.astra/repos/<repo>/` | 私有副本（含个人数据覆盖层） | 本地运行，.gitignore 屏蔽个人配置 |

### 项目索引（截至 v2.0）

| 项目 | GitHub | 说明 |
|:----|:------:|:------|
| **astra-sre** | ✅ | SRE 协调层：全设备巡检、健康检查、自动修复 |
| **astra-knowledge-base-mcp** | ✅ | 基于 SQLite + FTS5 的知识库 MCP 服务 |
| **astra-camofox-browser** | ✅ (fork) | 反检测浏览器自动化 |
| **astra-aiagent-infra** | ✅ | 本门户本身 + 生命周期钩子 |
| **astra-skill-execution-framework** | ✅ | 任务分类路由框架 |
| **astra-skill-change-safeguard** | ✅ | 变更前安全检查 |
| **astra-skill-deploy-register** | ✅ | 部署登记 |
| **astra-skill-pre-action-research** | ✅ | 预研检查 |
| **astra-skill-work-closure-check** | ✅ | 收尾闭环检查 |
| **hermes-agent-tutorial** | ✅ | 本书本身 |

> 所有项目均已公开至 GitHub：https://github.com/alrcatraz/

## 14.2 技能注册表

`registry.yaml` 是整个技能体系的注册中心：

```yaml
# registry.yaml 片段
skills:
  - name: astra-sre
    version: 2.1.0
    repo: astra-sre
    path: skills/devops/astra-sre.symlink
    description: "统一 SRE 协调层"
```

生命周期钩子（`lifecycle/astra-lifecycle-sync.py`）自动读取 registry.yaml，生成各类部署清单到目标 SKILL.md，保证组件状态与注册表一致。

## 14.3 快速开始

```bash
# 克隆门户
git clone https://github.com/alrcatraz/astra-aiagent-infra.git
cd astra-aiagent-infra

# 查看注册表
cat registry.yaml

# 同步生命周期清单
uv run python3 lifecycle/astra-lifecycle-sync.py --update
```

所有 astra-* 组件及其能力均可通过门户仓库一站式查阅。
