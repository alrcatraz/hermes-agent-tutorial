# 第10章：SearXNG 部署与搜索配置 {#ch:10}

## 10.1 什么是 SearXNG？

SearXNG 是一个自托管的**元搜索引擎**——它不自己爬网页，而是把搜索请求转发给
多个上游搜索引擎（Google、Bing、Brave、Wikipedia 等），聚合结果后返回。

在 Hermes Agent 中，SearXNG 作为 `web.search_backend`，为 `web_search` 工具
提供搜索能力。它的核心优势：

- **隐私优先** —— 你的搜索请求不直接发给 Google/Bing
- **灵活配置** —— 可以自由选择哪些上游启用
- **国内部署友好** —— 只启用国内可达的上游即可
- **零 API 费用** —— 大部分内置引擎无需 API Key

## 10.2 Podman 部署

### 创建网络

```bash
podman network create searxng-net
```

### 启动 Valkey（缓存与限速）

```bash
podman run -d --name searxng-valkey --network searxng-net \
 docker.io/valkey/valkey:9-alpine valkey-server --save 60 1
```

### 记录 Valkey IP

```bash
VALKEY_IP=$(podman inspect searxng-valkey --format \
 '{{.NetworkSettings.Networks.searxng-net.IPAddress}}')
```

### 准备配置目录

```bash
mkdir -p ~/.local/share/searxng/core-config
```

### 启动 SearXNG 核心容器

!!! info "端口映射说明"
    `-p 127.0.0.2:8931:8888` 是 Podman 的标准语法，格式为 `绑定地址:宿主机端口:容器端口`。这里将容器的 8888 端口映射到宿主机的 8931 端口，并绑定到 127.0.0.2 实现隔离。容器启动后通过 `http://127.0.0.2:8931/` 访问。

```bash
podman run -d --name searxng-core --network searxng-net \
 -p 127.0.0.2:8931:8888 \
 -v ~/.local/share/searxng/core-config:/etc/searxng:Z \
 --add-host valkey:$VALKEY_IP \
 -e SEARXNG_BIND_ADDRESS=0.0.0.0 \
 -e SEARXNG_PORT=8888 \
 docker.io/searxng/searxng:latest
```

!!! note "提示"
    使用 `127.0.0.2:8931` 而不是 `127.0.0.1`，实现 Loopback 隔离。端口 `8931` 避免与常见服务冲突。

### 启用 JSON 格式（Hermes 需要）

编辑 `settings.yml`（在配置目录中），在 `search:` → `formats:` 下添加：

```yaml
search:
 formats:
  - html
  - json
```

然后重启容器：

```bash
podman restart searxng-core
```

### 验证部署

```bash
# 健康检查
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.2:8931/

# 搜索测试（必须用 POST）
curl -s --max-time 20 -X POST -d "q=test&format=json" \
 "http://127.0.0.2:8931/search" | python3 -c \
 "import sys,json; d=json.load(sys.stdin); print(f'结果数: {len(d.get(\"results\",[]))}')"
```

### 部署后加固（推荐）

SearXNG 在 Rootless Podman 上有三个常见故障模式，建议全部处理：

**1. 设置容器重启策略**

容器默认 `restart=no`，崩溃后不会自动恢复：

```bash
podman update --restart=always searxng-core
podman update --restart=always searxng-valkey
```

**2. 创建 Systemd 用户服务（开机自启）**

```bash
podman generate systemd --new --name searxng-core > ~/.config/systemd/user/searxng-core.service
podman generate systemd --new --name searxng-valkey > ~/.config/systemd/user/searxng-valkey.service

systemctl --user daemon-reload
podman stop searxng-core searxng-valkey
systemctl --user enable --now container-searxng-core container-searxng-valkey
```

**3. 配置 Limiter（避免 429）**

Rootless Podman 下需要将桥接网络加入白名单：

```toml
# ~/.local/share/searxng/core-config/limiter.toml
[botdetection]
trusted_proxies = []

[botdetection.ip_lists]
pass_ip = [
  '127.0.0.0/8',
  '::1',
  '10.89.1.0/24',
]
```

重启容器生效：

```bash
podman restart searxng-core
```

**4. 容器生命周期检查清单**

```bash
# 1. 容器是否在运行？
podman ps -a

# 2. 重启策略是否设置？
podman inspect searxng-core --format '{{.HostConfig.RestartPolicy.Name}}'

# 3. 是否有 systemd 服务？
systemctl --user list-units --type=service | grep searxng

# 4. 开机自启是否启用？
systemctl --user is-enabled container-searxng-core

# 5. 端口映射是否真的工作？
curl -s --max-time 10 -X POST -d 'q=test&format=json' \
  "http://127.0.0.2:8931/search" | python3 -c \
  "import sys,json; print(len(json.load(sys.stdin).get('results',[])), 'results')"
```

!!! note "提示"
    Rootless Podman 的端口映射（pasta）会在系统休眠/唤醒后静默断开，即使 `podman ps` 显示 "Up"。始终用真实 curl 验证。

## 10.3 搜索引擎上游选择

SearXNG 支持数十个上游引擎，但默认大部分是关闭的。
编辑 `settings.yml`，找到想启用的引擎，删除 `disabled: true` 一行即可。

### 无需 API Key 的推荐引擎

!!! info "测试环境"
    以下为 2026-06-18 实测可达性。部分国际引擎在国内网络环境下被阻断。

| 引擎 | 直连可达 | 说明 |
|:-----|:--------:|:-----|
| google | ❌ | 国内直连不可用，需代理 |
| duckduckgo | ❌ | 国内直连被 DNS 污染/阻断 |
| bing | ✅ | 国内直连可用，推荐启用 |
| brave | ❌ | 国内直连不可用，需代理 |
| startpage | ❌ | 国内直连不可用，需代理 |
| wikipedia | ✅ | 国内可用 |
| arxiv | ✅ | 学术论文，国内可用 |
| github | ✅ | 代码搜索，国内可用 |
| bilibili | ✅ | 国内视频内容 |
| baidu | ✅ | 国内首选中文搜索 |
| sogou | ✅ | 国内中文搜索备选 |
| qwant | ❌ | 国内直连不可用，需代理 |

!!! info "须知"
    StackOverflow 引擎使用专用 API 端点，SearXNG 正常支持。

!!! tip "技巧"
    国内部署建议分层启用：

    - **中文首选：** Baidu、Sogou、Bilibili（直连可用）
    - **国际内容：** Bing、Wikipedia、arXiv、GitHub（直连可用）
    - **需代理：** Google、DuckDuckGo、Brave、Qwant、StartPage（需通过代理访问，可选启用）

### 启用引擎示例

在 `settings.yml` 中找到对应引擎，删除 `disabled: true` 行：

```yaml
# 启用前
- name: bing
 disabled: true
 engine: bing
 # ...

# 启用后
- name: bing
 engine: bing
 # ...
```

## 10.4 集成到 Hermes

### 配置环境变量

在 `~/.hermes/.env` 中添加：

```bash
SEARXNG_URL="http://127.0.0.2:8931"
```

### 配置 config.yaml

```yaml
web:
  search_backend: searxng
```

!!! note "提示"
    SearXNG 是**纯搜索后端**，仅返回标题、URL 和摘要。如需提取网页完整内容，需配合支持 `web_extract` 的后端（见 [§10.6](#sec:10.6)）。

### Hermes 支持的 Web 搜索后端

Hermes 官方支持以下八种 Web 搜索后端：

| 后端 | 搜索 | 提取 | 部署方式 | 国内可用 | 适用场景 |
|:-----|:----:|:----:|:--------|:--------:|:--------|
| `searxng` | ✅ | ❌ | 自托管 | ✅（选好上游） | **推荐**，隐私可控，免费 |
| `firecrawl` | ✅ | ✅ | API 服务 | 需代理 | 全功能：搜索 + 网页抓取 |
| `tavily` | ✅ | ✅ | API 服务 | 需代理 | 生产环境，结构化结果 |
| `exa` | ✅ | ✅ | API 服务 | 需代理 | 语义搜索 + 内容提取 |
| `parallel` | ✅ | ✅ | API 服务 | 需代理 | 并行搜索 + 提取 |
| `brave` | ✅ | ❌ | API 服务 | 需代理 | Brave Search API |
| `ddgs` | ✅ | ❌ | 内置 | 需代理 | DuckDuckGo 搜索（无需 API Key） |
| `xai` | ✅ | ❌ | API 服务 | 需代理 | xAI 搜索集成 |

!!! info "关键区别"
    只有 `firecrawl`、`tavily`、`exa`、`parallel` 同时支持搜索和网页内容提取（`web_extract`）。其余后端（`searxng`、`brave`、`ddgs`、`xai`）仅提供搜索，无法提取完整网页内容。使用纯搜索后端时，可用 MarkItDown MCP 工具（[见第11章](11-markitdown.md#ch:11)）独立提取网页内容。

## 10.5 常见问题

### SearXNG 的局限性

SearXNG 是**纯搜索后端**，只能返回标题、URL 和简介。
它**不支持** `web_extract` 工具（无法提取网页完整内容）。
如需提取完整网页内容，有以下选择：

- 切换到同时支持搜索和提取的后端：`firecrawl`、`tavily`、`exa`、`parallel`
- 保持 SearXNG 作为搜索后端，通过启用 Plugin（例如 `web-extract-markitdown` Plugin）来自动处理网页提取——Plugin 会替换内置 `web_extract` 工具的后端，Agent 无需在对话中手动调用 MCP 工具（参考实现见 [§10.6](#sec:10.6)）

### 搜索失败/超时

```bash
# 检查容器网络
podman exec searxng-core ping -c 1 8.8.8.8

# 检查上游引擎状态
curl -s http://127.0.0.2:8931/stats | head -50

# 查看容器日志
podman logs searxng-core 2>&1 | grep -E '429|ERROR|timeout' | tail -20
```

如果 DuckDuckGo 持续返回 CAPTCHA 错误，这是国内防火墙的正常行为——换用
Bing 或 Brave 即可。

### 容器重启后端口映射丢失

Rootless Podman 的端口映射（pasta）偶尔会静默丢失。表现为容器在运行
但端口不通。修复：

```bash
podman restart searxng-core
```

### 查看当前启用的引擎

```bash
curl -s http://127.0.0.2:8931/config | python3 -c \
 "import sys,json; c=json.load(sys.stdin); [print(e['name']) for e in c['engines'] if not e.get('disabled')]"
```

## 10.6 Web 提取后端（Extract Backend） {#sec:10.6}

### 搜索与提取的区别

SearXNG 是**元搜索引擎**——它的职责是搜索并返回**摘要数据**
（标题、URL、简介片段）。当你需要**完整网页内容**时，需要一个支持 `web_extract`
的后端。

| 角色 | 后端 | 输入 | 输出 |
|:-----|:-----|:-----|:-----|
| 搜索 | SearXNG / Brave / DDGS / Tavily 等 | 搜索词 | 结果列表（标题 + URL + 摘要） |
| 提取 | Firecrawl / Tavily / Exa / Parallel | URL | 完整页面 Markdown 内容 |

在 Hermes Agent 中，搜索和提取可以统一配置（使用全功能后端），也可以分离：

```yaml
# ~/.hermes/config.yaml
web:
  search_backend: searxng       # 搜索：元搜索引擎（纯搜索）
  extract_backend: firecrawl    # 提取：需要单独配置支持 extract 的后端
```

### 支持提取的后端

只有以下四个后端同时支持搜索和网页内容提取（`web_extract`）：

| 后端 | 提取能力 | 说明 |
|:-----|:--------|:-----|
| `firecrawl` | ✅ | 全功能网页抓取，支持 JS 渲染 |
| `tavily` | ✅ | 结构化提取，生产环境推荐 |
| `exa` | ✅ | 语义搜索 + 内容提取 |
| `parallel` | ✅ | 并行搜索 + 批量提取 |

!!! note "提示"
    Hermes 支持通过 Plugin 自定义提取后端。你可以编写 Plugin 来替换 `web_extract` 工具的实现（例如使用 Jina Reader API、本地 MarkItDown MCP 服务等），无需依赖上述四个全功能后端。参考实现见[第19章](../volume-3/19-markitdown-extract.md)的 MarkItDown MCP 提取方案。

如果你使用 Firecrawl 等后端，以下是常见问题和应对策略：

1. **Firecrawl JS 渲染：** `firecrawl` 后端内置 JS 渲染，部分可绕过
2. **代理访问：** 通过 SOCKS5/HTTP 代理访问目标网站
3. **降级策略：** 只使用 SearXNG 返回的摘要信息

---
