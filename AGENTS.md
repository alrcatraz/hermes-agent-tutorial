# Hermes Agent Tutorial — Agent Guide

本文件记录 Hermes Agent 完全教程项目在制作过程中积累的工作规范、常见陷阱和最佳实践。

## 项目概览

多文件 MkDocs 源码，同时输出 Web（mkdocs-material）和 PDF（Pandoc + LuaLaTeX）。

- **Web:** `uvx --with mkdocs-material mkdocs serve`（预览）/ `mkdocs build`（构建）
- **PDF:** `make pdf`（Pandoc → LuaLaTeX）
- **源码位置:** `src/` 下分 volume-1/ volume-2/ volume-3/ appendix/ diagrams/
- **构建后文件:** `build/hermes-agent-tutorial.pdf`

## 内容规范

### 章节编号与锚点

每个章节必须有唯一锚点，格式如下：

```
# 第X章：标题 {#ch:X}
## X.Y 小节标题 {#sec:X.Y}
```

锚点用于交叉引用，必须唯一且稳定（改章节名不改锚点）。

### 交叉引用规范

| 引用类型 | 格式 | 示例 |
|:---------|:-----|:------|
| 同文件小节 | `[§X.Y](#sec:X.Y)` | `见 [§10.6](#sec:10.6)` |
| 其他章节 | `[第X章](path.md#ch:X)` | `见 [第11章](11-markitdown.md#ch:11)` |
| 其他章节小节 | `[第X章 §X.Y](path.md#sec:X.Y)` | `见 [第15章 §15.4](../volume-3/15-credentials.md#sec:15.4)` |

**禁止使用：**
- 裸 `§X.Y` 没有超链接 —— 必须在提示块内外都加上链接
- 裸 URL 没有 Markdown 链接语法 —— 必须包裹为 `[url](url)`
- 混合使用"第X章"和"第X章（汉字数字）" —— 统一使用阿拉伯数字

### 提示块（Admonitions）内的链接

mkdocs-material 的提示块内，Markdown 链接语法完全可用。**禁止**在提示块内使用裸文字引用章节号而不加链接。

```markdown
!!! note "正确示例"
    详见 [第17章](../volume-3/17-work-principles.md) 工作原则 Skill 体系。
```

### 插图规范

**优先使用 SVG**（Graphviz dot 生成），禁止使用 ASCII 示意图（用缩进和箭头绘制的流程/结构图）。

创建 SVG 流程：
1. 在 `src/diagrams/` 下创建 `.dot` 文件
2. 用 `dot -Tsvg input.dot -o output.svg` 渲染
3. 在 markdown 中引用 `![描述](../diagrams/output.svg)`
4. 检查渲染后的 SVG 尺寸 —— 文字太多时注意换行，避免画面过宽

当前已有 SVG 及其用途：

| SVG 文件 | 用途 | 章节 |
|:---------|:-----|:-----|
| `principle-to-skill.svg` | SOUL→Plugin→Skill 流水线 | 18 |
| `lifecycle-sync.svg` | 部署管线（dev→private→hermes） | 17 |
| `lifecycle-sync-hooks.svg` | LIFECYCLE_HOOKS 注入流程 | 17 |
| `context-anchor.svg` | Context Anchor 架构（Graphviz 重做） | 19 |
| `rag-flow.svg` | RAG 基本流程（三行竖排布局） | 17 |
| `credentials-architecture.svg` | 凭据管理双系统 | 15 |
| `credentials-dir-tree.svg` | credentials/ 目录结构 | 15 |
| `kb-pg-structure.svg` | PostgreSQL 知识库架构 | 17 |
| `kb-decision-tree.svg` | 信息分级存储决策树 | 17 |
| `sag-pipeline.svg` | SAG 事件抽取流水线 | 17 |
| `plugin-structure.svg` | Plugin 结构 | 18 |
| `markitdown-workflow.svg` | MarkItDown 工作流 | 11 |
| `search-flow.svg` | SearXNG 搜索+Plugin提取流程 | 10 |
| `doc-pipeline.svg` | 双输出管线 | 22 |

### 扩展 Markdown 语法

- `[第X章](path.md#ch:X)` — 超链接锚点用 `{#ch:X}` 格式挂载到 H1
- `{#sec:X.Y}` — 挂载到 H2/H3 作为小节锚点
- 行内标记 `` `code` `` 正常使用
- 加粗 `**text**` 和斜体 `*text*` 在提示块内外均有效

**注意：** 在提示块内的代码块（缩进 4 空格 + 代码用 `` ` `` 包裹）可能渲染异常。提示块内使用内联代码 `` ` `` 没问题。

### 版本号管理

版本号记录在 `README.md` 的 YAML frontmatter 中（`version: X.Y.Z`）。
每次修改 PDF/Web 输出前更新版本号。
当前版本历史：1.0 → 2.0（首次 SVG 引入）→ 3.0（交叉引用标准化 + 缺失 SVG 补齐）→ 3.1（封面自动同步、章节重编号、24 章新增、SVG 重画）。

## 常见陷阱

### 1. 提示块内的 HTML 注释残留

过去曾多次在提示块内留下的 `<!-- 注释 -->` 忘记清理。每次修改后要全面扫描 HTML 注释。

**检查命令：** `grep -r '<!--' src/ | grep -v 'LIFECYCLE_HOOKS'`

### 2. SVG 引用不存在

引用的 SVG 文件不存在，导致 MkDocs 或 PDF 编译的警告/缺失。
**检查命令：** 从 markdown 中提取 `![...](...svg)` 并核对 `src/diagrams/` 下是否存在。

### 3. 子节编号与父节不匹配

`21-office-tools.md` 曾出现 `### 19.4.1`（错误）应为 `### 21.4.1` 的情况。复制粘贴模板时容易残留旧编号。

**检查规则：** `## X.Y` 下的 `###` 子节必须以 `X.Y.Z` 开头。

### 4. 交叉引用格式不一致

曾经混合使用 `§10.6`（无链接）、`第10章`（无链接）、`[见第10章](path.md#ch:10)`（有链接）三种格式。**必须统一为可点击的 Markdown 链接。**

### 5. PDF 编译与 Web 渲染差异

- PDF（Pandoc + LuaLaTeX）支持自定义 Lua filters（admonitions、inline-code-bg、diagram-path）
- Web（MkDocs）支持 admonition 原生语法但语法略有不同
- 两者的 SVG 路径解析方式不同（`filters/diagram-path.lua` 负责 PDF 端的路径重写）

**必须在 Web 和 PDF 两种输出中都验证。**

### 6. 封面日期/版本号硬编码

`astra-doc-style.sty` 中的封面日期和版本号曾被硬编码为旧值。修复后改用 `Makefile` 在编译时从 `README.md` YAML 提取，写入 `styles/_coverdate.tex` 临时文件，通过 `-H` 注入。修改 `README.md` 的 `version` 或 `date` 后会自动同步到封面。

**检查命令：** `grep '\\coverdate' styles/astra-doc-style.sty && grep 'coverdate' Makefile`

### 7. 章节换页机制

如果 `\section` 被重新定义为 `\clearpage\section`，封面后的首个 `\section{引言}` 会产生空白页。修复方案：不要在 `\section` 重定义中包含 `\clearpage`，改为在每个章节的 `.md` 文件第一行加 `\newpage`。

**检查命令：** `grep -r '\\\\newpage' src/volume-*/ | grep '^[^:]*:[1]:'`

## 构建流水线

### Web 预览

```bash
cd ~/Projects/astra/hermes-agent-tutorial
uvx --with mkdocs-material mkdocs serve --dev-addr 127.0.0.2:8932
```

### PDF 编译

```bash
make pdf
# 等价于：
pandoc \
  src/pdf-metadata.yaml \
  src/introduction.md src/volume-1/*.md src/volume-2/*.md src/volume-3/*.md src/appendix/*.md \
  --pdf-engine=lualatex \
  --listings \
  --lua-filter=filters/admonitions.lua \
  --lua-filter=filters/inline-code-bg.lua \
  --lua-filter=filters/diagram-path.lua \
  --highlight-style=tango \
  -V colorlinks=true \
  -V geometry:margin=1in \
  -H styles/_coverdate.tex \
  -H styles/astra-doc-style.sty \
  -o build/hermes-agent-tutorial.pdf
```

### 交付前检查清单

1. ⬜ 无残留 HTML 注释（`grep -rn '<!--' src/ | grep -v LIFECYCLE_HOOKS`）
2. ⬜ 所有 SVG 引用指向存在的文件
3. ⬜ 所有 `§X.Y` 都已改为 `[§X.Y](#sec:X.Y)` 链接
4. ⬜ 所有章节 H2/H3 有 `{#sec:X.Y}` 锚点
5. ⬜ 子节编号与父节匹配（无 `19.x.y` 在 `21.x` 下的情况）
6. ⬜ 提示块内的交叉引用都有超链接（不是裸文字）
7. ⬜ 无 ASCII 示意图（graphviz SVG 替代）
8. ⬜ 所有 URL 是 Markdown 链接（不是裸 URL）
9. ⬜ Web 预览正常（`mkdocs serve`）
10. ⬜ PDF 编译通过（`make pdf`）
11. ⬜ 版本号已更新
12. ⬜ 本 AGENTS.md 同步更新新发现的工作规范

## 编辑策略

修改本教程文件时，遵循 "先修项目 → 验证 → 形成发布版 → 更新教程" 的流程：

1. **先修项目** — 如果是教程指向的外部项目（astra-* 生态组件）有问题，先去修对应项目代码
2. **确认可用** — 验证修好的项目正常工作
3. **形成发布版** — 在工作副本中完成所有改动
4. **最后改教程** — 所有外部修正确认后，再更新教程文档内容
