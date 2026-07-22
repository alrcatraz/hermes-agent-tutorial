# 附录A：核心概念速览 {#appendix:a}

## A.1 核心概念

每次你和 Hermes 的对话就是一个**会话**。Hermes 自动保存所有会话，可以随时回溯。

```bash
# 查看近期会话
hermes sessions list

# 继续上次的会话
hermes --continue
```


## A.2 工具（Tool）与工具集（Toolset）

Hermes 的能力来自于它可调用的**工具**。工具按功能分组为**工具集（Toolset）**：

```
web        web_search, web_extract
terminal   运行终端命令
file       read_file, write_file, search_files, patch
delegation delegate_task（子智能体）
cronjob    定时任务
vision     图像分析
memory     持久记忆
```

查看已启用的工具：

```bash
hermes tools list
```

## A.3 Plugin（插件）

Plugin 是 Hermes 的扩展机制——可以在不修改核心代码的前提下添加自定义工具、生命周期钩子和 CLI 命令。

```bash
# 查看已安装的 plugin
hermes plugins list

# 启用/禁用
hermes plugins enable <name>
hermes plugins disable <name>
```

Plugin 使用 **生命周期钩子**（Hook）与 Hermes 交互：

| 钩子 | 触发时机 | 典型用途 |
|:-----|:---------|:---------|
| `pre_llm_call` | 每次 LLM 调用前 | 修改系统提示词、注入上下文 |
| `post_tool_call` | 每次工具调用后 | 记录状态、更新上下文 |
| `pre_tool_call` | 每次工具调用前 | 阻断违规操作 |

常见 Plugin 示例：context-anchor（跨会话上下文锚定）、web-extract-markitdown（本地网页提取）。

## A.4 MCP（模型上下文协议）

MCP 是连接 Hermes 与外部服务的标准化协议。通过 MCP 服务器，Hermes 可以访问知识库、文件系统、数据库等外部资源。MCP 工具与 Hermes 内置工具的调用方式对 Agent 完全透明。

```bash
# 查看已配置的 MCP 服务器
hermes mcp list

# 重新加载 MCP 服务器
/reload-mcp
```

## A.5 CLI（命令行界面）

Hermes 的核心运行模式是 CLI，通过终端直接交互：

| 命令 | 用途 |
|:-----|:-----|
| `hermes` | TUI（终端界面）模式 |
| `hermes chat -q "问题"` | 单次查询 |
| `hermes --continue` | 继续上次会话 |
| `hermes gateway run` | 启动 Gateway 守护进程 |
| `hermes desktop` | 启动桌面 GUI |

CLI 命令行及命令行工具也是 Hermes Agent 在操作系统中使用工具的主要形式。

## A.6 技能（Skill）

技能是 Hermes 最有特色的功能之一：一个可复用的工作流程文档。

```bash
# 查看已安装的技能
hermes skills list

# 从技能中心搜索
hermes skills search deployment
```

技能使 Hermes 具备"自我改进"的能力——它从每次成功的任务中学习新流程。

## A.7 记忆（Memory）

| 层级 | 工具 | 说明 | 寿命 |
|:-----|:-----|:-----|:-----|
| 用户画像 | `memory` 工具 | 你的偏好、名字、习惯 | 永久 |
| 环境记忆 | `memory` 工具 | 系统配置、项目结构 | 永久 |
| 全息记忆 | `fact_store` | 深度实体关系推理 | 永久 |
| 会话历史 | `session_search` | 过去的对话内容 | 按保留策略 |

## A.8 Gateway（网关）

Gateway 是 Hermes 的跨平台消息网关。通过它，你可以通过 QQ、微信、Telegram、Matrix 等 15+ 平台远程使用 Hermes：

- 在手机上通过 **QQ 或微信**让 Hermes 在电脑上执行任务
- 通过 **Matrix** 接收定时任务的推送通知
- 让团队在 **Slack** 中共享同一个 Hermes Agent

!!! tip "给国内用户"
    QQ 和微信是首选的 Gateway 平台，体验最好。海外用户推荐 Telegram 和 Matrix。Gateway 的详细配置见正文[第5章](../volume-1/05-gateway.md#ch:5)。

## A.9 Agent 的两个主要运行模式

| 模式 | 启动方式 | 适用场景 |
|:-----|:---------|:---------|
| CLI 模式 | `hermes` 或 `hermes --tui` | 桌面端交互，实时对话 |
| Gateway 模式 | `hermes gateway run` | 跨平台远程使用，后台运行 |
