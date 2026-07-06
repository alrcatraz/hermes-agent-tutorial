# 第2章：安装前准备 {#ch:2}

Hermes Agent 支持 **Linux、macOS 和 Windows（WSL 2 或原生）**。如果你的电脑已经是 Linux，可以直接跳到[第3章](03-installation.md#ch:3)开始安装。

如果你用的是 **Windows**，有两种选择：通过 WSL 2 安装 Linux 子系统，或原生 Windows 安装。本章介绍 WSL 2 的配置方式；原生安装方式见[第3章](03-installation.md#ch:3)。

## 2.1 Windows 用户：启用 WSL 2

### 检查系统要求

WSL 2 要求 Windows 10 版本 2004+（Build 19041+）或 Windows 11。

### 安装 WSL

以管理员身份打开 **PowerShell**，运行：

```powershell
wsl --install
```

这个命令会自动：

1. 启用 WSL 功能
2. 设置 WSL 2 为默认版本
3. 安装默认的 Ubuntu 发行版

!!! note "提示"
    如果系统中已经安装了 WSL 1，运行 `wsl --set-default-version 2` 切换到 WSL 2。

### 验证安装（Ubuntu 用户）

安装完成后重启电脑。首次启动 Ubuntu 时会提示创建 Linux 用户名和密码。验证安装：

```bash
wsl --version
```

输出应类似：

```
WSL 版本： 2.x.x.x
内核版本： 5.15.x.x
WSLg 版本： 1.x.x
```

### 镜像网络模式（推荐，解决网络问题）

WSL 2 默认使用 NAT 网络，这会导致网络地址和 Windows 主机不同，代理配置经常出问题。建议启用 **镜像网络模式（Mirrored Networking）**：

在 Windows 用户目录下创建或编辑 `.wslconfig` 文件：

```
路径: C:\Users\你的用户名\.wslconfig
```

```ini
[wsl2]
networkingMode=mirrored
dnsTunneling=true
firewall=false
autoProxy=true
```

!!! tip "技巧"
    `autoProxy=true` 会自动继承 Windows 的 HTTP 代理设置。如果你在 Windows 上运行 Clash/FlClash/V2Ray 等代理工具，WSL 内部会自动使用这些代理，无需额外配置。

保存后重启 WSL：

```powershell
wsl --shutdown
wsl
```

### 安装其他 Linux 发行版（可选）

WSL 支持同时安装多个发行版。以下是三个示例发行版：

#### Ubuntu 24.04 LTS（默认）

如果已用 `wsl --install` 安装，默认就是 Ubuntu。如需指定版本：

```powershell
wsl --install -d Ubuntu-24.04
```

Ubuntu 的包管理命令：

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git python3 python3-venv pip -y
```

#### AlmaLinux OS 10

AlmaLinux 是 RHEL 的免费二进制兼容发行版：

```powershell
wsl --install -d AlmaLinux-10
```

AlmaLinux 的包管理命令（`dnf`）：

```bash
sudo dnf update -y
sudo dnf install curl git python3 python3-venv python3-pip -y
```

#### openSUSE Tumbleweed（滚动更新）

openSUSE Tumbleweed 提供最新的软件包，适合喜欢尝鲜的用户：

```powershell
wsl --install -d openSUSE-Tumbleweed
```

Tumbleweed 的包管理命令（`zypper`）：

```bash
sudo zypper refresh
sudo zypper update -y
sudo zypper install curl git python3 python3-venv python3-pip -y
```

!!! tip "技巧"
    - Ubuntu 是最容易上手的选择，社区文档丰富，推荐新手从此开始
    - 如果你喜欢尝鲜、保证你的系统和内核总是最新的，那 openSUSE Tumbleweed 是最适合你的
    - 如果你希望与服务器环境接轨，那么 AlmaLinux OS 和 openSUSE Leap 将会更适合你

### 代理配置

如果你在 Windows 上使用代理工具（如 Clash、v2ray、FlClash 等），有两种方式让 WSL 中的 Hermes 也能使用代理：

**方式一：镜像网络自动代理（推荐）**

如果启用了 `autoProxy=true`（见镜像网络模式一节），WSL 会自动继承 Windows 的代理设置。验证：

```bash
env | grep -i proxy
```

**方式二：手动设置环境变量**

```bash
# 一个范例设置，具体端口根据真实情况修改
echo 'export http_proxy=http://127.0.0.1:7890' >> ~/.bashrc
echo 'export https_proxy=http://127.0.0.1:7890' >> ~/.bashrc
source ~/.bashrc
```

!!! warning "注意"
    代理端口取决于你的代理工具设置，请根据实际端口修改。

测试代理是否工作：

```bash
curl -I https://www.google.com
```

## 2.2 macOS 用户

macOS 用户可以直接在终端中操作，无需 WSL：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install python@3.11 git curl
```

## 2.3 Linux 用户

确保以下工具已安装：

```bash
# Ubuntu / Debian
sudo apt install curl git python3 python3-venv -y

# AlmaLinux / Fedora / RHEL
sudo dnf install curl git python3 python3-venv -y

# openSUSE
sudo zypper install curl git python3 python3-venv -y
```

确认 Python 版本为 3.10+：

```bash
python3 --version
```

!!! tip "技巧"
    本教程后续的所有操作都在 Linux 环境中进行（无论是原生 Linux 还是 WSL 中的 Linux）。

## 2.4 注册与获取 API Key

Hermes Agent 本身是免费的，但它需要调用 **大语言模型（LLM）** 来完成你的指令。这些模型由第三方服务提供，通常需要 API 密钥来认证。

!!! info "原理"
    Hermes Agent = 免费的开源框架 + 付费（或免费额度）的模型 API。这就像浏览器本身是免费的，但访问网站需要网络一样。

### 2.4.1 推荐：DeepSeek

DeepSeek 是 Hermes Agent 的**首选 Provider**：

| 优势 | 说明 |
|:-----|:------|
| 价格 | 行业最低，输入 $0.14/百万 token，输出 $0.28/百万 token |
| 性能 | deepseek-v4-flash 速度快，deepseek-v4-pro 推理强 |
| 国内可达 | 从中国可直接访问，无需代理 |
| 中文支持 | 原生中文理解能力极佳 |

#### 注册与获取 API Key

1. 打开 DeepSeek 开发者平台：**[platform.deepseek.com](https://platform.deepseek.com)**
2. 点击右上角的 **"Sign Up"** 注册
3. 进入 **"API Keys"** 页面，点击 **"Create API Key"**
4. 输入名称（如 `hermes-agent`），点击确认创建
5. **立即复制并保存密钥**——只显示一次：

   ```
   Your API Key: sk-xxx...xxxx
   ```

!!! warning "注意"
    密钥相当于你的账户密码。不要分享给他人，不要在公开代码中写入。

6. （可选）充值：新账户通常有免费额度，用完可在 **Billing** 页面充值。

### 2.4.2 备选：其他 Provider

#### OpenAI

- 注册：**platform.openai.com**
- 环境变量名：`OPENAI_API_KEY`

#### OpenRouter

- 注册：**openrouter.ai**
- 特点：聚合数十个模型，一个密钥访问多个
- 环境变量名：`OPENROUTER_API_KEY`

#### 智谱 BigModel（Z.AI，辅助任务主力）

智谱开放平台（bigmodel.cn）提供多个免费的 Flash 系列模型，
作为**辅助任务的主力模型**（视觉识别、网页摘要、对话压缩等）：

- 注册：**bigmodel.cn** → 创建 API Key
- 环境变量名：`GLM_API_KEY`
- 费用：**完全免费**
- 国内直连：可用 无 GFW 问题

#### HuggingFace（可选备用）

HuggingFace Inference Providers 可作为备用方案：

- 注册：**huggingface.co/join**
- 环境变量名：`HF_TOKEN`
- 端点：`https://router.huggingface.co/v1`（新端点）
- 特点：免费用户每月 $0.10 额度

#### Mistral（免费层级）

Mistral 提供免费 API 额度，适合作为补充搜索或轻量任务的后备：

- 注册：**console.mistral.ai** → 创建 API Key
- 环境变量名：`MISTRAL_API_KEY`
- 费用：**免费层级**（每日有请求数限制）
- 端点：`https://api.mistral.ai/v1`
- 特点：`mistral-small-latest` 免费可用，适合轻量推理



## 2.5 本章小结

| Provider | 用途 | 费用 | 必须配置？ |
|:---------|:-----|:-----|:----------|
| **DeepSeek** | 主对话模型 | 极低 | 强烈推荐 |
| **智谱 BigModel** | 辅助任务（主力） | **免费** | 推荐 |
| OpenAI / OpenRouter | 备用 | 中等 | 可选 |

!!! tip "技巧"
    现在只需 DeepSeek 的 API Key 就够了。其他按需注册。

---
