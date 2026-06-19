# 第十二章：Agent 定制（SOUL 与 Personality） {#ch:12}

## 12.1 配置即身份

Hermes Agent 的个性塑造来自两个层次：

- **SOUL（系统级）**：定义了 Agent 的工作原则和身份定位。每个会话自动加载。
- **Personality（风格级）**：定义了回复的语气、风格和口头禅。通过 `hermes config set display.personality` 切换。

## 12.2 SOUL 文件

SOUL 文件是 Hermes Agent 的“宪法”，定义了：

- Agent 的身份名称和定位
- 工作原则（先保全再改、诚实优先等）
- 安全准则
- 质量标准

SOUL 文件通常位于 `~/.hermes/SOUL.md`，每次新会话时自动加载。

## 12.3 Personality 风格

Hermes 内置了多种 personality：

| 名称 | 风格 | 适用场景 |
|:----|:----|:--------|
| `mentor` | 亦师亦友，活泼可爱 + 认真分享 | 个人助手（推荐） |
| `helpful` | 友好助手 | 通用场景 |
| `concise` | 简洁直接 | 高效问答 |
| `technical` | 技术专家风格 | 技术文档与排错 |
| `hacker` | —— | 系统管理 |
| `kawaii` | 萌系风格 | 日常聊天 |

```bash
# 切换 personality
hermes config set display.personality mentor
```

## 12.4 自定义 Personality

你可以在 `config.yaml` 的 `display.personalities` 段添加新的人格：

```yaml
agent:
  personalities:
    custom-name: |
      You are a pirate who speaks like a buccaneer...
```
