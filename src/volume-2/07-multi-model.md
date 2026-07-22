\\newpage

# 第7章：多模型协作配置 {#ch:7}

## 7.1 架构思路

不要把所有任务都扔给同一个大模型。按任务复杂度分配不同模型，
可以降低成本并提高响应速度。

| 角色 | 推荐 Provider | 典型模型 |
|:-----|:-------------|:---------|
| 主模型（对话、编码） | DeepSeek | deepseek-v4-flash |
| 子智能体（复杂推理） | DeepSeek | deepseek-v4-pro |
| 视觉理解 | 智谱 BigModel | **GLM-4.6V-Flash**（免费） |
| 网页摘要 | 智谱 BigModel | **GLM-4.7-Flash**（免费） |
| 对话压缩 | 智谱 BigModel | **GLM-4.7-Flash**（免费） |
| 标题生成 | 智谱 BigModel | **GLM-4.7-Flash**（免费） |
| 审批判断 | 智谱 BigModel | **GLM-4.7-Flash**（免费） |
| 任务分类 | 智谱 BigModel | **GLM-4.7-Flash**（免费） |
| 任务分解 | 智谱 BigModel | **GLM-4.7-Flash**（免费） |
| 用户画像 | 智谱 BigModel | **GLM-4.7-Flash**（免费） |
| 技能策展 | DeepSeek | deepseek-v4-pro |

!!! tip "智谱 BigModel"
    智谱 BigModel 的 Flash 模型全部免费，国内可直连。
    GLM-4.7-Flash 支持 200K 上下文，GLM-4.6V-Flash 支持 128K 视觉理解。

## 7.2 配置 API 密钥

**DeepSeek**

在 `~/.hermes/.env` 中添加：

```bash
DEEPSEEK_API_KEY=sk_your_deepseek_api_key_here
```

**智谱 BigModel（Z.AI）**

智谱开放平台（bigmodel.cn）提供免费的 Flash 系列模型。
注册后创建 API Key，在 `~/.hermes/.env` 中添加：

```bash
GLM_API_KEY=your_zhipu_api_key_here
```

!!! note "提示"
    Hermes 内置了 BigModel/Z.AI provider。`GLM_API_KEY` 是自动识别的环境变量名，无需手动配置 `base_url`。

## 7.3 配置主模型

```bash
hermes config set model.default "deepseek-v4-flash"
hermes config set model.provider "deepseek"
```

## 7.4 配置子智能体模型

子智能体可以独立使用其他模型：

```bash
hermes config set delegation.provider "deepseek"
hermes config set delegation.model "deepseek-v4-pro"
```

## 7.5 配置辅助任务

辅助任务有独立的 provider/model 设置，互不干扰。

### 配置智谱 BigModel (Z.AI)

`zai` 是 Hermes 内置的智谱 BigModel/Z.AI provider，**无需在 `providers:` 下定义**。只需设置 `GLM_API_KEY` 环境变量，然后用 `hermes config set` 直接配置各个辅助任务：

```bash
# Vision（视觉理解）
hermes config set auxiliary.vision.provider "zai"
hermes config set auxiliary.vision.model "GLM-4.6V-Flash"

# 对话压缩
hermes config set auxiliary.compression.provider "zai"
hermes config set auxiliary.compression.model "GLM-4.7-Flash"

# 标题生成
hermes config set auxiliary.title_generation.provider "zai"
hermes config set auxiliary.title_generation.model "GLM-4.7-Flash"

# 审批判断
hermes config set auxiliary.approval.provider "zai"
hermes config set auxiliary.approval.model "GLM-4.7-Flash"

# Web 提取
hermes config set auxiliary.web_extract.provider "zai"
hermes config set auxiliary.web_extract.model "GLM-4.7-Flash"

# MCP 辅助
hermes config set auxiliary.mcp.provider "zai"
hermes config set auxiliary.mcp.model "GLM-4.7-Flash"

# 技能集分析
hermes config set auxiliary.skills_hub.provider "zai"
hermes config set auxiliary.skills_hub.model "GLM-4.7-Flash"

# 任务分类
hermes config set auxiliary.triage_specifier.provider "zai"
hermes config set auxiliary.triage_specifier.model "GLM-4.7-Flash"

# 任务分解
hermes config set auxiliary.kanban_decomposer.provider "zai"
hermes config set auxiliary.kanban_decomposer.model "GLM-4.7-Flash"

# 用户画像
hermes config set auxiliary.profile_describer.provider "zai"
hermes config set auxiliary.profile_describer.model "GLM-4.7-Flash"

# 技能策展
hermes config set auxiliary.curator.provider "deepseek"
hermes config set auxiliary.curator.model "deepseek-v4-pro"
```

## 7.6 智谱 BigModel 免费模型一览

智谱开放平台提供以下免费 Flash 系列模型：

| 模型 | 类型 | 上下文 | 用途 |
|:-----|:-----|:------:|:-----|
| **GLM-4.7-Flash** | 文本对话 | 200K | 主力辅助任务 |
| **GLM-4.6V-Flash** | 多模态视觉 | 128K | 图像理解 |
| GLM-4V-Flash | 视觉（基础） | 16K | 备选视觉模型 |
| GLM-4-Flash-250414 | 文本 | 128K | 备选文本模型 |
| CogView-3-Flash | 文生图 | — | AI 绘图 |
| CogVideoX-Flash | 文生视频 | — | AI 视频生成 |

!!! note "提示"
    GLM-4.6V-Flash 白天高峰可能 429 限流，可换用 GLM-4V-Flash。

## 7.7 验证配置

```bash
hermes doctor
```

或用 Hermes `chat -q` 测试：

```bash
# 测试文本辅助模型
hermes chat -q "你好，请回复OK"

# 测试视觉模型（需要图片）
hermes chat -q "描述这张图" --attach path/to/image.jpg
```

或用 curl 直接测试智谱 API：

```bash
curl -X POST "https://open.bigmodel.cn/api/paas/v4/chat/completions" \
  -H "Authorization: Bearer *** \
  -H "Content-Type: application/json" \
  -d '{
    "model": "GLM-4.7-Flash",
    "messages": [{"role": "user", "content": "OK"}],
    "max_tokens": 10
  }'
```

---
