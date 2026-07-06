# 第23章：开发者指南 {#ch:23}

!!! note "面向读者"
    如果你想为 Astra 生态贡献新组件、开发自定义 Skill/Plugin/MCP 服务，本章提供完整的开发标准参考。

## Skill 开发

### SKILL.md 格式

```yaml
---
name: astra-<domain>-<name>
description: "<一句话描述>"
version: 1.0.0
author: <你的 GitHub 用户名>
platforms: [linux]
---
Skill正文
```

- name 必须 `astra-` 前缀 + kebab-case
- 版本号遵循语义化版本 2.0.0

### 触发条件

使用汉英双语的触发关键词，让 Hermes 在遇到相关任务时自动加载该 skill。

## Plugin 开发

Hermes 的 plugin 系统支持 `override=True` 替换内置工具。详见[官方文档](https://hermes-agent.nousresearch.com/docs/guides/build-a-hermes-plugin/)。

### Plugin 结构

Plugin 目录包含以下文件，每个文件有明确的职责划分：

| 文件 | 用途 |
|:-----|:------|
| `plugin.yaml` | 清单文件 |
| `__init__.py` | `register(ctx)` 注册接口 |
| `hooks.py` | 生命周期钩子实现 |
| `schemas.py` | 工具 schema 定义 |
| `tools.py` | 工具逻辑实现 |
| `state.py` | 状态持久化 |

Plugin 通过注册生命周期钩子与 Hermes 运行时交互：

| 钩子 | 触发时机 | 典型用途 |
|:-----|:---------|:---------|
| `pre_llm_call` | LLM 调用前 | 修改系统提示词 |
| `post_tool_call` | 工具调用后 | 记录 SSH 跳转、更新状态 |
| `pre_tool_call` | 工具调用前 | 阻断违反原则的操作 |

### 关键：override=True

替换内置工具需要在 `register()` 中传入 `override=True`：
```python
ctx.register_tool(
    name="web_extract",
    toolset="plugin_web_extract",
    schema=schemas.WEB_EXTRACT,
    handler=tools.web_extract,
    override=True,
)
```

启用时需授权：
```bash
hermes plugins enable <name> --allow-tool-override
```

## MCP 服务开发

MCP 服务是独立的进程，通过 stdio 或 HTTP 与 Hermes 通信。
详见[官方 MCP 文档](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp)。

## Astra 生态标准

所有组件必须遵守 [`astra-aiagent-infra/docs/module-development-guide.md`](https://github.com/alrcatraz/astra-aiagent-infra) 中的标准：

| # | 检查项 | 说明 |
|:-:|:-------|:-----|
| 1 | README.md | 存在，含 Badge Bar + 双语 |
| 2 | SKILL.md | 含 YAML frontmatter |
| 3 | LICENSE | MIT |
| 4 | registry.yaml | 已在 meta-repo 注册 |
| 5 | 版本一致性 | registry + 本地一致 |
| 6 | Hub 索引 | 在 astra-hub 中列出 |
| 7 | routing.yaml | 如需 execution-framework 自动发现 |

## 双副本工作流

| 位置 | 角色 |
|:-----|:------|
| `~/Projects/astra/<component>/` | 开发副本，可推送 GitHub（需脱敏） |
| `~/.astra/repos/<component>/` | 私有副本，Hermes 实际加载 |
| `~/.hermes/...` | 软链接，指向私有副本 |

开发副本推送前需注意脱敏：无本地路径硬编码、无个人凭证、无本地配置。

---
