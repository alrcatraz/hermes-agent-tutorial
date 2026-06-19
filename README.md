---
version: 2.0.0
---

# Hermes Agent Complete Tutorial

<div align="center">

[![License](https://badgen.net/github/license/alrcatraz/hermes-agent-tutorial)](LICENSE)
[![GitHub stars](https://badgen.net/github/stars/alrcatraz/hermes-agent-tutorial)](https://github.com/alrcatraz/hermes-agent-tutorial)
[![GitHub last commit](https://badgen.net/github/last-commit/alrcatraz/hermes-agent-tutorial)](https://github.com/alrcatraz/hermes-agent-tutorial/commits)
[![Sponsor](https://img.shields.io/github/sponsors/alrcatraz?label=Sponsor&logo=github&color=ea4aaa&logoColor=white)](https://github.com/sponsors/alrcatraz)

**Like this tutorial?** [Sponsor me on GitHub](https://github.com/sponsors/alrcatraz) — every bit supports more open-source documentation and tools. ❤️

> From scratch installation · Quick start · Advanced configuration  
> CC BY-SA 4.0 (text) · MIT (code examples) © 2026 [alrcatraz](https://github.com/alrcatraz)

</div>

---

**Hermes Agent** is an open-source AI agent framework developed by **Nous Research**.

This tutorial takes you from zero to production. Available as both a [web site](https://alrcatraz.github.io/hermes-agent-tutorial/) and a PDF:

- **Volume I — Basics (Chapters 1–6)** — Installation, initial configuration, Gateway setup, work principles
- **Volume II — Intermediate (Chapters 7–12)** — Multi-model collaboration, external memory, SearXNG, MarkItDown, Agent customisation
- **Volume III — Advanced (Chapters 13–20)** — Knowledge base, Skills, credential management, SRE, browser automation, Office tools
- **Appendix** — Concepts reference, toolchain comparison, full config example, FAQ

It is the companion tutorial of the [Astra ecosystem](https://github.com/alrcatraz/astra-aiagent-infra).

## Project Structure

```
hermes-agent-tutorial/
├── src/                           ← Markdown source files
│   ├── index.md                   ← Site home page
│   ├── introduction.md            ← Standalone introduction
│   ├── volume-1/                  ← 6 chapters
│   ├── volume-2/                  ← 6 chapters
│   ├── volume-3/                  ← 8 chapters
│   ├── appendix/                  ← 4 appendix sections
│   └── diagrams/                  ← Pre-rendered SVG diagrams
├── styles/
│   └── astra-doc-style.sty        ← LaTeX styles (PDF)
├── filters/
│   ├── admonitions.lua            ← Admonition blocks
│   ├── inline-code-bg.lua         ← Inline code grey background
│   └── diagram-path.lua           ← SVG path resolution
├── .github/
│   ├── FUNDING.yml                ← GitHub Sponsors
│   └── workflows/
│       └── deploy.yml             ← Auto-deploy to GitHub Pages
├── mkdocs.yml                     ← MkDocs configuration
├── Makefile                       ← Build both web & PDF
├── LICENSE                        ← Dual license
└── README.md
```

## Building

### Web site

```bash
# Serve locally (http://127.0.0.1:8000)
uvx --with mkdocs-material mkdocs serve

# Build to site/ directory
uvx --with mkdocs-material mkdocs build
```

The GitHub Actions workflow in `.github/workflows/deploy.yml` automatically builds and deploys to GitHub Pages on every push to `main`.

### PDF

```bash
make pdf
# or manually:
pandoc \
  src/introduction.md \
  src/volume-1/*.md \
  src/volume-2/*.md \
  src/volume-3/*.md \
  src/appendix/*.md \
  --pdf-engine=lualatex \
  --listings \
  --lua-filter=filters/admonitions.lua \
  --lua-filter=filters/inline-code-bg.lua \
  --lua-filter=filters/diagram-path.lua \
  --highlight-style=tango \
  -V colorlinks=true \
  -V geometry:margin=1in \
  -H styles/astra-doc-style.sty \
  -o build/hermes-agent-tutorial.pdf
```

## Related

- [Astra AI Agent Infra](https://github.com/alcatraz/astra-aiagent-infra) — ecosystem portal & component registry
- [Hermes Agent](https://hermes-agent.nousresearch.com/) — official documentation

## License

**Text content:** CC BY-SA 4.0 — share and adapt with attribution and share-alike.  
**Code examples:** MIT — free to use in any project, no strings attached.

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=alcatraz/hermes-agent-tutorial&type=date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=alcatraz/hermes-agent-tutorial&type=date" />
    <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=alcatraz/hermes-agent-tutorial&type=date" width="600" />
  </picture>
</div>

---

CC BY-SA 4.0 (text) · MIT (code examples) © 2026 [alcatraz](https://github.com/alcatraz)
