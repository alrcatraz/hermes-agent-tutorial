# 第九章：Gateway 会话打断配置 {#ch:9}

## 9.1 什么是会话打断？

在 Gateway 模式下（通过 Telegram、Discord、Matrix 等平台使用 Hermes），
Agent 处理任务时可能需要一些时间。**会话打断**允许你在 Agent 正在工作时，
直接发一条新消息 —— 它会停止当前处理，立即响应你的新指令。

## 9.2 打断时发生了什么？

1. **正在执行的终端命令** —— 立即被终止（SIGTERM，1秒后 SIGKILL）
2. **正在进行的工具调用** —— 被取消
3. **Agent 的思考过程** —— 丢弃，转而处理新消息

## 9.3 配置打断行为

`busy_text_mode` 控制 Gateway 在 Agent 忙碌时的行为：

```yaml
agent:
 busy_text_mode: interrupt
```

| 模式 | 行为 | 适用场景 |
|------|------|:--------:|
| `interrupt` | 新消息立即打断当前处理 | **推荐** |
| `queue` | 新消息排队，完成后处理 | 重要操作不想中断 |
| `steer` | 在下次工具调用后插入指令 | 精细控制 |

!!! tip "技巧"
    大多数场景使用 `interrupt`。如果在执行关键操作（如数据库迁移），可临时切换到 `queue`。

## 9.4 超时控制

```yaml
agent:
  gateway_timeout: 1800           # 单次请求最大等待（秒）
  gateway_timeout_warning: 900    # 超时前多久发警告
  gateway_notify_interval: 180    # 进度通知间隔
  gateway_auto_continue_freshness: 3600  # 自动继续的时限
```
