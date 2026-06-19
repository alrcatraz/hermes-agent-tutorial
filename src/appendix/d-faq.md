# 附录D：常见问题 {#appendix:d}

**Q: 智谱 BigModel 模型返回 401？**

A: 确认两件事：

1. `.env` 中有 `GLM_API_KEY` 且值正确
2. 辅助任务中没有误设 `base_url` 和 `api_key`（`zai` 是内置 provider，不要手动设置）

**Q: 智谱模型返回 429 Too Many Requests？**

A: 白天高峰时段可能限流。Vision 模型可换用 `GLM-4V-Flash` 作为备选。

**Q: HuggingFace 模型不可用？**

A: 如果配置了 HuggingFace 作为备用，确认三件事：

1. Token 权限中勾选了 `"Make calls to Inference Providers"`
2. `base_url` 已设置为 `https://router.huggingface.co/v1`（不是旧端点）
3. 免费额度未耗尽（每月 $0.10）

**Q: 从中国搜索不到结果/搜索失败？**

A: 如果使用 SearXNG，检查上游搜索引擎的可用性。DuckDuckGo 在国内经常
被阻断，建议在 SearXNG 配置中启用 Bing、Brave 等国内可达的
上游，或者使用百度百科、知乎等中文源。详见[第十章](#ch:10)。

**Q: Gateway 配置后没有反应？**

A: 按以下顺序排查：

1. 运行 `hermes gateway status` 检查平台是否在线
2. 如果离线，检查 Token 是否填写正确（用 `cat ~/.hermes/.env | grep TOKEN`）
3. 重启 Gateway：`hermes gateway restart`
4. 如果是首次配置，确保已运行一次 `hermes gateway run` 来启动守护进程
5. 查看日志：`journalctl --user -u hermes-gateway --no-pager -n 30`

**Q: 辅助任务修改后不生效？**

A: 需要 `/reset`（CLI 模式）或 `/restart`（Gateway 模式）才能生效。

**Q: MarkItDown MCP 不工作？**

A: 确认 `markitdown-mcp` 已安装（`uv tool install markitdown-mcp`），
运行 `hermes mcp list` 查看状态，运行 `/reload-mcp` 重新加载。

**Q: 如何查看当前配置？**

```bash
hermes config        # 查看完整配置
hermes config env-path   # 查看 .env 路径
hermes auth list      # 查看已配置的 Provider 凭证
hermes doctor        # 诊断配置健康状态
```

**Q: 记忆太多怎么办？**

A: 使用 `fact_feedback` 标记无用事实，系统会自动降权。
Holographic Memory 的信任评分机制会逐渐将有效事实排在前面。

**Q: Cron 任务出现 Broken pipe / 管道断裂错误？**

A: 通常是因为 agent 驱动的 cron 在执行长时间脚本（如 SSH 扫描多台设备）时，stdout
管道超时关闭。解决方法是转换为 `no_agent=true` 模式——脚本作为独立子进程运行，
stdout 直接投递，无需 LLM 中转，零管道断裂风险。

**Q: LLM 驱动的 cron 任务超时或卡死？**

A: 对于纯脚本任务（数据收集、状态检查），使用 `no_agent=true` 模式绕过 LLM，
脚本 stdout 直接投递。对于需要总结、筛选、判断的任务才使用 agent 模式。
详见第[二十章](#ch:20)的运行时选择原则。

**Q: Gateway E2EE 消息无法解密？**

A: 常见原因：设备 ID 缓存冲突或过期的 One-Time Keys（OTK）。

1. SSH 到 Gateway 所在服务器
2. 运行 `hermes gateway restart` 刷新 OTK
3. 如果问题持续，在 Element 客户端中重置会话：设置 → 会话 → 删除 Hermes 会话 → 重新登录

**Q: GPG 预缓存口令失效？**

A: `gpg-preset-passphrase` 默认缓存有效期约 10 分钟。对于长期运行的 cron job，
需要在 cron 脚本开头重新执行预缓存命令。另一个方案是将 GPG 缓存超时
（`gpg-agent.conf` 中的 `default-cache-ttl`）设置为较大的值（如 28800 秒=8 小时）。

**Q: `hermes doctor` 报告 Provider 不可达？**

A: 国内网络环境中，部分 Provider API 端点可能被阻断。按以下顺序排查：

1. 测试 API 可用性（如 `curl -I https://api.openai.com/v1/models`）
2. 如果不可达，检查代理/VPN 是否正常（特别是全局模式）
3. 配置多 Provider 回退（详见第[七章](#ch:7)多模型协作）
4. 使用 `hermes gateway status` 确认 Gateway 平台在线

---

*基于 Hermes Agent 实际部署和配置经验编写。*

*参考文档：https://hermes-agent.nousresearch.com/docs/*

*仓库：https://github.com/nousresearch/hermes-agent*

**本文档的测试环境：**

| 项目 | 配置 |
|:-----|:-----|
| 主力机器 | openSUSE Tumbleweed / GNOME Wayland |
| CPU | Intel i5 8250U |
| 内存 | 8 GB DDR4 2666 SO-DIMM |
| 安装方式 | curl 一行命令安装器 |
| Gateway 平台 | Matrix（自建 Synapse 服务） |
| 搜索后端 | 自托管 SearXNG（Podman + Valkey） |
