# 第十三章：关于 Astra 生态 {#ch:13}

!!! info "本卷说明"
    本卷部分组件属于 **Astra 生态**。Astra 生态是作者 alrcatraz 个人构建的开源扩展体系——它们并非 Hermes Agent 官方功能，而是基于 Hermes 的插件（Plugins）、MCP 服务器、技能（Skills）等扩展体系实现的**个人实践**。这些组件已在作者的生产环境中运行，可作为自建参考。

## 13.1 组件总览

截至本书发布时，Astra 生态包含以下已公开的 GitHub 项目：

| 项目 | GitHub | 许可证 | 说明 |
|:----|:------:|:------|:-----|
| **astra-aiagent-infra** | ✅ 已公开 | MIT | 生态门户：项目索引、技能注册表、生命周期钩子 |
| **astra-sre** | ✅ 已公开 | MIT | SRE 协调层：全设备巡检、健康检查、自动修复 |
| **astra-knowledge-base-mcp** | ✅ 已公开 | MIT | 多租户知识库 MCP 服务（SQLite + FTS5 后端） |
| **astra-camofox-browser** | ✅ 已公开 | MIT | 反检测浏览器封装，用于自动化场景 |
| **astra-skill-execution-framework** | ✅ 已公开 | MIT | 任务分类与工作流路由框架 |
| **astra-skill-change-safeguard** | ✅ 已公开 | MIT | 变更前安全审计 Skill |
| **astra-skill-deploy-register** | ✅ 已公开 | MIT | 部署登记自动化 Skill |
| **astra-skill-pre-action-research** | ✅ 已公开 | MIT | 预研检查 Skill |
| **astra-skill-work-closure-check** | ✅ 已公开 | MIT | 收尾闭环检查 Skill |
| **hermes-agent-tutorial** | ✅ 已公开 | CC BY-SA 4.0 | 本书本身 |

每个组件的详细介绍和配置方式，在后续各章中展开。

!!! note "注意"
    后续各章首部的「本章对应 Astra 生态组件」标记仅在该章涉及的组件属于 Astra 生态时出现。不属于 Astra 生态的章节（如第十八章的 Office 工具）则不会带有此标记。
