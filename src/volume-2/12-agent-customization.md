\\newpage

# 第12章：Agent 定制（SOUL 与 Personality） {#ch:12}

## 12.1 配置即身份

Hermes Agent 的个性塑造来自两个层次：

- **SOUL（系统级）**：定义了 Agent 的工作原则和身份定位。每个会话自动加载。
- **Personality（风格级）**：定义了回复的语气、风格和口头禅。通过 `hermes config set display.personality` 切换。

## 12.2 SOUL 文件

SOUL 文件定义了 Agent 的身份、语气。与普通 Prompt 不同，SOUL 在**每个会话启动时无条件注入**。

## 12.3 Personality 风格

Hermes 内置了多种 personality：

| 名称 | 风格 | 类别 |
|:----|:----|:----|
| `helpful` | 友好助手 | 基础 |
| `concise` | 简洁直接 | 基础 |
| `technical` | 技术专家风格 | 基础 |
| `creative` | 创意发散 | 基础 |
| `teacher` | 教师讲解 | 基础 |
| `noir` | 黑色电影侦探 | 角色扮演 |
| `philosopher` | 哲人思辨 | 角色扮演 |
| `pirate` | 海盗口吻 | 角色扮演 |
| `shakespeare` | 莎士比亚戏剧腔 | 角色扮演 |
| `surfer` | 冲浪者腔调 | 角色扮演 |
| `kawaii` | 日系萌系 | 趣味 |
| `catgirl` | 猫娘口吻 | 趣味 |
| `uwu` | uwu 语癖 | 趣味 |
| `hype` | 高能激燃 | 趣味 |

> **注意**：上表列出的是 Hermes 原生的 14 种内置 personality，自定义 personality 的配置方法见 [12.4 节](#12.4)。

```bash
# 切换 personality
hermes config set display.personality technical
```

## 12.4 自定义 Personality {#12.4}

你可以在 `config.yaml` 的 `display.personalities` 段添加新的人格：

```yaml
agent:
  personalities:
    custom-name: |
      You are a pirate who speaks like a buccaneer...
```

---
