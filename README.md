---
version: 1.0.0
---

# Hermes Agent Complete Tutorial

> From scratch installation · Quick start · Advanced configuration  
> CC BY-SA 4.0 © 2026 Nanaly

---

Hermes Agent is an open-source AI agent framework developed by **Nous Research**.

This tutorial takes you from zero to production, covering installation, configuration, and advanced tuning:

- **Volume I (Chapters 1–7)** — Beginner's guide, step-by-step installation and configuration
- **Volume II (Chapters 8–14)** — Advanced configuration, multi-model collaboration, Gateway tuning
- **Volume III (Chapters 15–21)** — Enterprise deployment, SRE operations, ecosystem integration

## Directory Structure

```
hermes-agent-tutorial/
├── src/
│   └── hermes-tutorial-combined.md   ← Tutorial source file
├── styles/
│   └── astra-doc-style.sty          ← LaTeX styles
├── filters/
│   └── inline-code-bg.lua           ← Inline code rendering
├── build/                           ← Compiled output (PDF)
├── LICENSE                          ← CC BY-SA 4.0
└── README.md
```

## Building

```bash
cd src
pandoc hermes-tutorial-combined.md \
  --pdf-engine=xelatex \
  --lua-filter=../filters/inline-code-bg.lua \
  --highlight-style=tango \
  -V colorlinks=true \
  -V geometry:margin=1in \
  -H ../styles/astra-doc-style.sty \
  -o ../build/hermes-agent-tutorial.pdf
```

## License

This tutorial is licensed under **CC BY-SA 4.0** — you are free to share and adapt it, provided you give appropriate credit and share under the same licence.

## Dependencies

This tutorial is written from scratch and has no external dependencies.

---

## 中文版

### Hermes Agent 完全教程

Hermes Agent 是一个由 **Nous Research** 开发的开源 AI 代理框架。

本教程带你从零基础开始，逐步走过安装、配置、到高级调优的完整路径：

- **第一卷（第一～七章）** — 新手入门，手把手安装配置
- **第二卷（第八～十四章）** — 进阶配置，多模型协作、Gateway 调优
- **第三卷（第十五～二十一章）** — 企业级部署，SRE 运维、生态集成

### 目录结构

```
hermes-agent-tutorial/
├── src/
│   └── hermes-tutorial-combined.md   ← 教程源文件
├── styles/
│   └── astra-doc-style.sty          ← LaTeX 样式
├── filters/
│   └── inline-code-bg.lua           ← 内联代码渲染
├── build/                           ← 编译输出（PDF）
├── LICENSE                          ← CC BY-SA 4.0
└── README.md
```

### 编译

```bash
cd src
pandoc hermes-tutorial-combined.md \
  --pdf-engine=xelatex \
  --lua-filter=../filters/inline-code-bg.lua \
  --highlight-style=tango \
  -V colorlinks=true \
  -V geometry:margin=1in \
  -H ../styles/astra-doc-style.sty \
  -o ../build/hermes-agent-tutorial.pdf
```

### 许可证

本教程采用 **CC BY-SA 4.0** 许可 —— 你可以自由分享和改编，但必须署名并以相同方式共享。

### 依赖关系

本教程内容完全原创，不依赖任何外部存储库。
