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
delegation delegate_task（子代理）
cronjob    定时任务
vision     图像分析
memory     持久记忆
```

查看已启用的工具：

```bash
hermes tools list
```

## A.3 技能（Skill）

技能是 Hermes Agent 最有特色的功能之一：一个可复用的工作流程文档。

```bash
# 查看已安装的技能
hermes skills list

# 从技能中心搜索
hermes skills search deployment
```

技能使 Hermes 具备“自我改进”的能力——它从每次成功的任务中学习新流程。

## A.4 记忆（Memory）

| 层级 | 工具 | 说明 | 寿命 |
|:-----|:-----|:-----|:-----|
| 用户画像 | `memory` 工具 | 你的偏好、名字、习惯 | 永久 |
| 环境记忆 | `memory` 工具 | 系统配置、项目结构 | 永久 |
| 全息记忆 | `fact_store` | 深度实体关系推理 | 永久 |
| 会话历史 | `session_search` | 过去的对话内容 | 按保留策略 |

## A.5 Gateway（网关）

Gateway 是 Hermes 的跨平台消息网关。通过它，你可以通过 QQ、钉钉、Telegram、Matrix、微信等 15+ 平台远程使用 Hermes：

- 在手机上通过 **QQ 或钉钉**让 Hermes 在电脑上执行任务
- 通过 **Matrix** 接收定时任务的推送通知
- 让团队在 **Slack** 中共享同一个 Hermes Agent

!!! tip "给国内用户"
    QQ 和钉钉是首选的 Gateway 平台，体验最好。微信的支持有限。海外用户推荐 Telegram 和 Matrix。Gateway 的详细配置见正文[第五章](#ch:5)。

## A.6 Agent 的两个主要运行模式

| 模式 | 启动方式 | 适用场景 |
|:-----|:---------|:---------|
| CLI 模式 | `hermes` 或 `hermes --tui` | 桌面端交互，实时对话 |
| Gateway 模式 | `hermes gateway run` | 跨平台远程使用，后台运行 |
