\\newpage

# 第13章：关于 Astra 生态 {#ch:13}

!!! info "本卷说明"
    本卷部分组件属于 **Astra 生态**。Astra 生态是作者 alrcatraz 个人构建的开源扩展体系——它们并非 Hermes Agent 官方功能，而是基于 Hermes 的插件（Plugins）、MCP 服务器、技能（Skills）等扩展体系实现的**个人实践**。这些组件已在作者的生产环境中运行，可作为自建参考。

## 13.1 组件总览

截至本教程当前版本，Astra 生态包含以下已公开的 GitHub 项目：

| 项目 | 版本 | 许可证 | 说明 |
|:----|:----:|:------|:-----|
| **[astra-aiagent-infra](https://github.com/alrcatraz/astra-aiagent-infra)** | v1.3.0 | MIT | 生态门户：项目索引、技能注册表、生命周期钩子、Agentic Harness |
| **[astra-knowledge-base-mcp](https://github.com/alrcatraz/astra-knowledge-base-mcp)** | v1.2.0 | MIT | 多租户知识库 MCP 服务（PostgreSQL 16 + pgvector） |
| **[astra-sre](https://github.com/alrcatraz/astra-sre)** | v1.0.1 | MIT | SRE 协调层：全设备巡检、健康检查、自动修复 |
| **[astra-camofox-browser](https://github.com/alrcatraz/astra-camofox-browser)** | v1.0.0-astra.1 | MIT | 反检测浏览器封装（Astra Fork） |
| **[astra-skill-execution-framework](https://github.com/alrcatraz/astra-skill-execution-framework)** | v2.0.1 | MIT | 手动 keyword 技能推荐工具（已从 Agentic Harness 脱钩） |
| **[astra-web-extract-markitdown](https://github.com/alrcatraz/astra-web-extract-markitdown)** | v0.1.0 | MIT | Hermes Plugin：MarkItDown 文档转换增强 |
| **[astra-vcs-assist](https://github.com/alrcatraz/astra-vcs-assist)** | v1.0.1 | MIT | VCS 协作辅助：远程拓扑分析、fork 同步、GPG 签名管理 |
| **[hermes-agent-tutorial](https://github.com/alrcatraz/hermes-agent-tutorial)** | v3.1.0 | CC BY-SA 4.0 | 安装、配置和使用 Hermes Agent 的教程 |

每个组件的详细介绍和配置方式，在后续各章中展开。

!!! note "注意"
    后续各章首部的「本章对应 Astra 生态组件」标记仅在该章涉及的组件属于 Astra 生态时出现。不属于 Astra 生态的章节（如[第21章](../volume-3/21-camofox.md)的 Office 工具）则不会带有此标记。

---

## 附录：安装方式

Astra 生态的组件支持两种安装模式：

### 用户模式（仅使用）

适合只想使用组件、不打算参与开发的用户。直接拉取仓库到 `~/.astra/repo/` 下，并将对应的skill、plugin等通过软连接映射到 Hermes Agent 对应的目录即可使用。

```bash
# 克隆到私有副本
git clone https://github.com/alrcatraz/<component> ~/.astra/repos/<component>

# 建立软链接到 Hermes 加载路径
ln -sfn ~/.astra/repos/<component>/plugin ~/.hermes/plugins/<name>   # plugin
ln -sfn ~/.astra/repos/<component> ~/.hermes/skills/devops/<name>    # skill
```

### 开发者模式（双副本）

适合希望参与开发、推送到 GitHub 的开发者。除了 `~/.astra/repo/` 的副本，另外在 `~/Projects/astra/` 下维护一组不含个人信息、不作软连接的开发副本。

```bash
# 开发副本（可推送到 GitHub）
git clone https://github.com/alrcatraz/<component> ~/Projects/astra/<component>

# 私有副本（Hermes 实际加载）
git clone ~/Projects/astra/<component> ~/.astra/repos/<component>
```

详细标准见 [`astra-aiagent-infra/docs/module-development-guide.md`](https://github.com/alrcatraz/astra-aiagent-infra)。

---
