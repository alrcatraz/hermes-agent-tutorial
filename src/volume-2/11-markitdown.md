# 第十一章：MarkItDown MCP 工具：文件格式转换与网页读取
\label{ch:11}

## 11.1 什么是 MarkItDown MCP？

[MarkItDown](https://github.com/microsoft/markitdown) 是微软开源的
文档转 Markdown 工具，通过 MCP（Model Context Protocol）为 Hermes Agent
提供 `convert_to_markdown` 工具。它可以将各种格式的资源（网页、PDF、
Office 文档等）转换为 Markdown 文本，让 AI 模型可以直接理解和处理。

!!! info "重要区分"
    MarkItDown 是一个 **MCP 工具**，由 Agent 在对话中自主调用，**不是** Hermes 的 `web.extract_backend`。Web 提取后端（`web_extract`）由 `firecrawl`、`tavily`、`exa`、`parallel` 等后端提供（见第十章）。
    MarkItDown 作为 MCP 工具与搜索后端互补使用：Agent 搜索到 URL 后，可调用 `convert_to_markdown` 获取完整网页内容。

### MarkItDown 的能力

| 能力 | 说明 |
|:-----|:-----|
| 🌐 网页读取 | 将 `http://` 或 `https://` URL 转为 Markdown |
| 📁 本地文件 | 读取 `file://` 路径的文件并转换 |
| 📄 Office 文档 | .docx, .xlsx, .pptx → Markdown |
| 📝 PDF | PDF 文件内容提取 |
| 🖼️ 图片 OCR | 通过 OCR 插件提取图片文字（见 §11.5） |
| 🎵 音频 | 语音转文字 |
| 📦 压缩包 | 解压并转换包内文件 |

### 在 Hermes 中的角色

MarkItDown 在 Hermes 中的定位是 **Agent 工具箱中的文件/网页读取工具**，
而非后端基础设施。典型工作流：

![MarkItDown 工作流](../diagrams/markitdown-workflow.svg)

这与 `web_extract` 后端的区别在于：

- **Web 提取后端**（`extract_backend: firecrawl`）：系统级配置，`web_extract`
  工具自动路由到指定后端
- **MarkItDown MCP**：Agent 级别的工具调用，Agent 自行决定何时使用

## 11.2 安装

```bash
uv tool install markitdown-mcp
```

## 11.3 配置 MCP 服务器

在 `config.yaml` 中添加：

```yaml
mcp_servers:
 markitdown:
  command: markitdown-mcp
  timeout: 60
  enabled: true
```

或者通过 CLI：

```bash
hermes mcp add markitdown --command markitdown-mcp
```

## 11.4 使用 MarkItDown 读取网页和文件

MarkItDown MCP 会自动将 `convert_to_markdown` 工具注入到对话中。

支持的文件格式：

-  网页：`http://` 或 `https://` URL
-  本地文件：`file://` 路径
-  PDF、Office 文档（`.docx`, `.pptx`, `.xlsx`）
-  图片：`data:` URI 或 URL

!!! note "提示"
    - `read_file` 仍然是读取纯文本文件（代码、配置等）的首选工具
    - MarkItDown 主要用于**非纯文本**格式：PDF、Office 文档、网页

## 11.5 OCR 图片文字识别

MarkItDown MCP 可以通过 `markitdown-ocr` 插件启用图片 OCR 功能，
将图片中的文字提取为 Markdown。

### 11.5.1 安装 OCR 插件

```bash
pip install markitdown[ocr]
```

或者单独安装 OCR 依赖：

```bash
pip install markitdown-ocr
```

### 11.5.2 配置 GLM-4.6V-Flash 作为 OCR 后端

`markitdown-ocr` 支持多种视觉模型作为 OCR 后端。
推荐使用 **GLM-4.6V-Flash**（智谱免费多模态视觉模型），
通过 OpenAI 兼容 API 接入：

```yaml
# config.yaml
ocr:
  enabled: true
  provider: openai_compatible
  model: glm-4.6v-flash
  base_url: https://open.bigmodel.cn/api/paas/v4
  api_key: ${GLM_API_KEY}
```

或者使用环境变量：

```bash
export GLM_API_KEY="your-api-key"
```

### 11.5.3 OCR 使用示例

配置 OCR 后，`convert_to_markdown` 工具会自动对图片文件
执行 OCR 识别：

- 读取扫描版 PDF（每页作为图片 OCR）
- 图片文件中的文字提取（`.png`, `.jpg`, `.webp` 等）
- 图文混排文档的文字识别和结构保留

!!! note "提示"
    GLM-4.6V-Flash 是智谱提供的免费多模态模型，适合图片内容识别场景。需要注册智谱开放平台账号并获取 API Key。
