# Hermes Agent 完全教程

<div align="center" markdown="1">

> 从零安装 · 快速上手 · 高级配置  
> 三卷完整路线，带你成为 Hermes Agent 高手

[![License](https://img.shields.io/github/license/alrcatraz/hermes-agent-tutorial)](LICENSE)
[![GitHub stars](https://badgen.net/github/stars/alrcatraz/hermes-agent-tutorial)](https://github.com/alrcatraz/hermes-agent-tutorial)
[![GitHub last commit](https://badgen.net/github/last-commit/alrcatraz/hermes-agent-tutorial)](https://github.com/alrcatraz/hermes-agent-tutorial/commits)
[![Sponsor](https://img.shields.io/github/sponsors/alrcatraz?label=Sponsor&logo=github&color=ea4aaa&logoColor=white)](https://github.com/sponsors/alrcatraz)

</div>

---

**Hermes Agent** 是一个由 [Nous Research](https://nousresearch.com/) 开发的开源 AI 代理框架。
本教程带你从零开始，逐步学会安装、配置和定制自己的 Hermes Agent。

## 📚 内容导航

### 第一卷 · 基础配置

适合第一次接触 Hermes Agent 的新手：

| 章节 | 内容 | 预计阅读 |
|:----|:----|:-------:|
| [第1章：认识 Hermes Agent](volume-1/01-introduction.md) | 什么是 Hermes？它能做什么？ | 15 min |
| [第2章：安装前准备](volume-1/02-preparation.md) | 系统要求、环境配置、API Key 获取 | 20 min |
| [第3章：安装 Hermes Agent](volume-1/03-installation.md) | 多种安装方式对比与实操 | 15 min |
| [第4章：初次配置与启动](volume-1/04-initial-config.md) | Provider 配置、第一个对话 | 20 min |
| [第5章：配置 Gateway](volume-1/05-gateway.md) | Telegram/Matrix 接入、开机自启 | 15 min |
| [第6章：工作原则与偏好设置](volume-1/06-principles.md) | SOUL 工作原则、personality 配置 | 20 min |

### 第二卷 · 进阶设置

深入 Hermes 的核心能力：

| 章节 | 内容 | 预计阅读 |
|:----|:----|:-------:|
| [第7章：多模型协作配置](volume-2/07-multi-model.md) | 多 Provider 路由、辅助任务分配 | 20 min |
| [第8章：外部记忆](volume-2/08-memory.md) | Holographic Memory、持久化偏好 | 15 min |
| [第9章：Gateway 会话打断](volume-2/09-gateway-interrupt.md) | 超时控制、打断行为配置 | 10 min |
| [第10章：搜索后端（SearXNG）](volume-2/10-searxng.md) | 自建隐私搜索引擎 | 25 min |
| [第11章：网页和文件内容读取](volume-2/11-markitdown.md) | MarkItDown MCP、OCR 配置 | 15 min |
| [第12章：Agent 定制](volume-2/12-agent-customization.md) | SOUL 身份、personality 风格 | 20 min |

### 第三卷 · 高级设置（Astra 生态参考实现）

以 [Astra 生态系统](https://github.com/alrcatraz/astra-aiagent-infra) 为范例，构建生产级 Agent 基础设施：

| 章节 | 内容 | 领域 |
|:----|:----|:----:|
| [第13章：Astra 生态总览](volume-3/13-astra-intro.md) | 生态概览与组件定位 | 总览 |
| [第14章：Astra Hub——生态门户](volume-3/14-astra-hub.md) | 项目索引、服务注册、模板引擎 | 总览 |
| [第15章：登录凭据管理](volume-3/15-credentials.md) | GPG 加密注入、KeePassXC | 安全 |
| [第16章：知识库与信息分级储存](volume-3/16-knowledge-base.md) | MCP 知识库、三层存储架构 | 存储 |
| [第17章：工作原则 Skill 体系](volume-3/17-work-principles.md) | SOUL→Plugin→Skill 执行管线 | 工程 |
| [第18章：Context Anchor](volume-3/18-context-anchor.md) | 跨会话上下文锚定 | 集成 |
| [第19章：MarkItDown 网页提取后端](volume-3/19-markitdown-extract.md) | 本地 MarkItDown MCP Plugin | 文档 |
| [第20章：浏览器自动化与登录持久化（Camofox）](volume-3/20-camofox.md) | 电商价格监控、无头浏览器 | 自动化 |
| [第21章：Office 工具与文档撰写](volume-3/21-office-tools.md) | OfficeCLI、TeX Live、Pandoc | 办公 |
| [第22章：个人设备健康检测与自动维护（SRE）](volume-3/22-sre.md) | SRE 巡检、看门狗机制 | 运维 |
| [第23章：开发者指南](volume-3/23-developer-guide.md) | Plugin 开发、lifecycle-sync、部署管线 | 开发 |

### 附录

| 章节 | 内容 |
|:----|:----|
| [A：核心概念速览](appendix/a-concepts.md) | 会话、工具、技能、记忆速查 |
| [B：工具链介绍与对比](appendix/b-toolchain.md) | pip/uv/conda、npm、Podman/Docker、SQLite/PostgreSQL 等 |
| [C：完整配置范例](appendix/c-config-example.md) | 完整的 config.yaml + .env |
| [D：常见问题 Q&A](appendix/d-faq.md) | 安装/配置/使用中常见问题 |

---

## 🚀 快速开始

```bash
# 一行命令安装 Hermes Agent
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

详见[第3章：安装](volume-1/03-installation.md)

---

**CC BY-SA 4.0 (正文) · MIT (代码示例) © 2026 [alrcatraz](https://github.com/alrcatraz)**
