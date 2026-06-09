# Hermes Agent 完全教程

> 从零安装 · 快速上手 · 高级配置  
> CC BY-SA 4.0 © 2026 Nanaly

---

Hermes Agent 是一个由 **Nous Research** 开发的开源 AI 代理框架。

本教程带你从零基础开始，逐步走过安装、配置、到高级调优的完整路径：

- **第一卷（第一～七章）** — 新手入门，手把手安装配置
- **第二卷（第八～十四章）** — 进阶配置，多模型协作、Gateway 调优
- **第三卷（第十五～二十一章）** — 企业级部署，SRE 运维、生态集成

## 目录结构

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

## 编译

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

## 许可证

本教程采用 **CC BY-SA 4.0** 许可 —— 你可以自由分享和改编，但必须署名并以相同方式共享。
