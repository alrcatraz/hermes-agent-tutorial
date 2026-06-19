# 第四章：首次配置与启动 {#ch:4}

## 4.1 选择 Provider 和模型

安装完成后，最重要的第一步是配置你的 LLM Provider。

### 方式一：全功能设置向导 `hermes setup`（推荐）

```bash
hermes setup
```

这是一个全功能向导，覆盖 Provider、终端后端、Gateway、工具权限等所有配置项。

!!! tip "如果你使用了 curl 自动安装脚本"
    `hermes setup` 会在首次启动时自动运行，无需手动执行。

和下文 `hermes model` 不同——`hermes setup` 是完整的系统配置，而 `hermes model` 只做 Provider/模型选择。

**Nous Portal 用户**可以用一条命令完成所有配置：

```bash
hermes setup --portal
```

OAuth 一键登录，同时配置好模型 + 四项 Tool Gateway。

### 方式二：交互式选择 `hermes model`

```bash
hermes model
```

这是专门用于选择 Provider 和模型的轻量向导，Hermes 会以交互式菜单引导你完成：

1. 从列表中选出你的 Provider（如 DeepSeek、OpenAI 等）
2. 输入 API Key（或通过 OAuth 登录）
3. 选择具体模型（如 `deepseek-v4-flash`）
4. 保存配置

!!! tip "技巧"
    你可以随时切换 Provider——`hermes model` 没有锁定，想换就换。

### 方式三：手动配置

```bash
# 写入 API Key
echo 'DEEPSEEK_API_KEY=***' >> ~/.hermes/.env

# 设置 Provider 和模型
hermes config set model.default "deepseek-v4-flash"
hermes config set model.provider "deepseek"
```

!!! warning "注意"
    `.env` 文件包含敏感密钥，确保权限为 600：

    ```bash
    chmod 600 ~/.hermes/.env
    ```

## 4.2 验证配置

```bash
hermes doctor
```

这次应该没有 API Key 的警告了。

## 4.3 第一个对话

Hermes 提供两种终端界面：

### 经典 CLI

```bash
hermes
```

### 新式 TUI（推荐）

```bash
hermes --tui
```

TUI 模式提供模态窗口、鼠标选择和更现代化的界面。两种界面共享同一套会话和配置。

### 试试看

```
> 你好！你是谁？

> 查看当前目录下的文件

> 搜索一下 Hermes Agent 的最新版本是多少
```

!!! tip "技巧"
    第一次对话时，Hermes 可能会请求你批准执行某些命令——输入 `y` 同意，`n` 拒绝。

## 4.4 退出

输入 `/quit` 或按 `Ctrl+C` 退出。

## 4.5 常用启动方式

| 场景 | 命令 |
|:-----|:------|
| 普通对话（经典 CLI） | `hermes` |
| 普通对话（TUI，推荐） | `hermes --tui` |
| 单次查询 | `hermes chat -q "你的问题"` |
| 继续上次会话 | `hermes --continue` |
| 恢复特定会话 | `hermes --resume 会话ID` |
| 以特定模型启动 | `hermes -m deepseek-v4-pro` |

---

