# 第3章：安装 Hermes Agent {#ch:3}

## 3.1 三种安装方式对比

| 方式 | 推荐场景 | 优点 | 缺点 |
|:----------------------------|:-----------|:-----------|:----------|
| **curl 一行命令**（`curl ... \| bash`） | **新手首选** | 零前提条件，自动安装所有依赖 | 依赖 git |
| **pip 安装**（`pip install hermes-agent`） | Python 用户 | 最简（已有 Python 时） | 需自行准备 Python 3.11+ |
| **源码安装**（`git clone && pip install -e .`） | 开发者 | 方便修改代码 | 占用磁盘大 |

!!! info "官方推荐"
    官网首页和安装页面首推的是 curl 一行命令安装器。它不需要你事先安装 Python、Node.js——安装器自动通过 `uv` 全部搞定。pip 在 Quickstart 指南中列为 Option A，适合已有 Python 环境的用户。

## 3.2 curl 一行命令安装（推荐）

零前提条件，适合大多数用户：

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

这个脚本会自动安装：

1. `uv`（快速 Python 包管理器）

2. Python 3.11（通过 `uv`，无需 sudo）

3. Node.js v22（浏览器自动化和 WhatsApp 桥接）

4. `ripgrep`（快速文件搜索）

5. `ffmpeg`（音频格式转换）

6. 克隆 Hermes 仓库到 `~/.hermes/hermes-agent/`

7. 创建虚拟环境并安装依赖

8. 创建全局 `hermes` 命令

**安装完成后，脚本会自动启动交互式设置向导**（`hermes setup`），引导你配置 API 密钥和模型。如果当前没有终端（如 Docker 构建），向导会跳过，后续手动运行 `hermes setup` 即可。

如果要跳过自动设置，可以加上 `--skip-setup` 参数：

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash -s --skip-setup
```

刷新 shell：

```bash
source ~/.bashrc
hermes --version
```

### 如果已有 Python 环境：pip 安装

```bash
pip install hermes-agent

# （可选）安装附加组件
hermes postinstall
```

!!! info "说明"
    `hermes postinstall` 会安装浏览器自动化、TTS 等高级功能所需的依赖，可跳过，以后随时运行。

## 3.3 git 安装器（跟踪 main 分支）

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

### 安装布局

| 安装模式 | 代码位置 | hermes 命令 | 数据目录 |
|:---------|:---------|:------------|:---------|
| pip 安装 | Python site-packages | `~/.local/bin/hermes` | `~/.hermes/` |
| git 安装器（普通用户） | `~/.hermes/hermes-agent/` | `~/.local/bin/hermes` | `~/.hermes/` |
| root 模式（sudo） | `/usr/local/lib/hermes-agent/` | `/usr/local/bin/hermes` | `/root/.hermes/` |

### 可能遇到的错误

**`command not found: hermes`：**

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**`Permission denied`：**

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | sudo bash
```

## 3.4 Windows 用户：选择 WSL 还是原生安装？

Windows 用户有两种方式运行 Hermes——通过 WSL 2 装 Linux 或直接原生安装。

### Windows 原生安装（推荐）

Hermes 支持 Windows 原生运行——CLI、Gateway、TUI 和工具均原生工作，推荐大多数用户选择：

```powershell
iex (irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1)
```

安装器自动处理：`uv`、Python 3.11、Node.js 22、ripgrep、ffmpeg、PortableGit。
数据目录在 `%LOCALAPPDATA%\\hermes`。

原生安装还提供 GUI 界面（使用 Hermes Desktop）和 Computer Use 工具集成，开箱即用体验更好。

### WSL 2 安装（备选，适合需要完整 POSIX 环境的用户）

在 WSL 2 终端中运行 3.2 节的 curl 命令即可。WSL 提供完整的 Linux/POSIX 环境，所有功能都能正常使用。

### 对比

| 维度 | WSL 2 安装 | Windows 原生安装 |
|:-----|:-----------|:-----------------|
| 环境 | 完整的 Linux/POSIX 环境 | Windows 环境，内置 PortableGit |
| 兼容性 | 脚本和工具都按预期工作 | 绝大多数功能正常 |
| 缺陷 | 无 | Dashboard 嵌入式终端面板不可用 |
| 推荐给 | 追求功能完整、已配好 WSL 的用户 | 不想装 WSL、想最快跑起来的用户 |

!!! info "官方说明"
    两个安装可以共存，互不干涉。CLI、Gateway、Cron、Browser 工具、MCP 服务器在 Windows 原生下都正常工作。

## 3.5 桌面版安装

Hermes 也提供 macOS / Windows 原生桌面安装包：

[https://github.com/NousResearch/hermes-agent/releases](https://github.com/NousResearch/hermes-agent/releases)

桌面版首次启动时会自动调用安装脚本完成依赖配置。

## 3.6 源码安装（开发者）

```bash
git clone https://github.com/NousResearch/hermes-agent.git ~/.hermes/hermes-agent
cd ~/.hermes/hermes-agent
pip install -e .
```

## 3.7 验证安装

```bash
hermes doctor
```

健康输出类似：



```
Hermes CLI              v0.18.3
Python                  3.11.15
Linux kernel            6.7.0
Terminal backend        local
Provider: DeepSeek      ok
Provider: Z.AI          ok
Tool: web               ok
Tool: file              ok
Tool: terminal          ok
Tool: cronjob           ok
Holographic Memory      enabled (190 facts)
```

!!! note "提示"
    `API key not set` 是正常的——下一步就去配置。

---
