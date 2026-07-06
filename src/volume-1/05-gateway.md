# 第5章：配置 Gateway {#ch:5}

Gateway 是 Hermes Agent 的可选组件，但强烈推荐配置。通过 Gateway，你可以在手机上通过 QQ、钉钉、Telegram、Matrix 等平台远程操控 Hermes，不再局限于电脑前。

!!! info "原理"
    Hermes Gateway 本质上是一个消息桥接器——它监听各平台的收件箱，把收到的消息转发给 Hermes Agent 处理，然后再把回复发回平台。你不需要暴露任何端口到公网。

## 5.1 交互式配置

配置 Gateway 的首选方式：

```bash
hermes gateway setup
```

Hermes 会以交互式向导引导你完成平台选择、Token 输入和权限设置。支持的平台包括：

- **国内推荐：** QQ、钉钉
- **海外推荐：** Telegram、Matrix、Discord、Slack
- **其他：** WhatsApp、Signal、Email、SMS、飞书、企业微信等

## 5.2 手动配置

如果已经有平台 Token，可以直接写入 `.env`：

以 QQ 和微信为例——这两种是国内用户体验最好的 Gateway 平台：

```bash
# QQ (go-cqhttp / Lagrange)
echo 'QQ_WS_URL=ws://127.0.0.1:8080' >> ~/.hermes/.env

# 微信 (WeChat Ferret / wechaty)
echo 'WECHATY_PUPPET=wechaty-puppet-service' >> ~/.hermes/.env
```

## 5.3 验证配置

```bash
hermes gateway status
```

显示已配置的平台列表和在线状态。

## 5.4 安装为系统服务（开机自启）

### Linux（systemd）

```bash
# 安装为 systemd 用户服务
hermes gateway install

# 启动服务
hermes gateway start

# 查看状态
hermes gateway status

# 停止服务
hermes gateway stop

# 重启服务
hermes gateway restart
```

!!! note "提示"
    `hermes gateway install` 会创建一个 systemd 用户服务（`~/.config/systemd/user/hermes-gateway.service`），并启用开机自启。如果系统不支持 systemd，它会用 `nohup` 在后台启动。

!!! tip "没有 systemd 的环境"
    在 Termux 或没有 systemd 的环境下，使用 `hermes gateway run` 前台运行，或用 `nohup hermes gateway &` 后台运行。

### 安装时自动配置

curl 安装器在检测到消息平台 Token 后，会主动询问：

```text
Would you like to install the gateway as a background service? [Y/n]
```

选择 `Y` 就会自动运行 `hermes gateway install` + `hermes gateway start`，一步到位。

---
