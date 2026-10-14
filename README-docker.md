# Docker 部署（本 fork 的定制 additions）

> 本文件是本 fork 新增的 Docker 部署文档，上游仓库不存在此文件，同步上游时不会被覆盖。
> 主 [README.md](README.md) 保持与上游完全一致。

本仓库提供 `Dockerfile` 和 `docker-compose.yml`，基于 [lipanski/docker-static-website](https://github.com/lipanski/docker-static-website)（BusyBox httpd 静态服务器），单阶段构建、无需编译。

## 快速开始

方式一：docker compose（推荐）

```bash
docker compose up -d
```

方式二：手动构建运行

```bash
docker build -t ra2web:latest .
docker run -d \
  --name ra2web \
  --restart always \
  --log-opt max-size=1m \
  --log-opt max-file=1 \
  -p 5157:5157 \
  ra2web:latest
```

启动后访问 http://localhost:5157 即可游玩。如需更换宿主端口，修改 `-p 宿主端口:5157` 或在 compose 中追加 `command: ["-p", "自定义端口"]` 并同步修改端口映射。

多架构镜像（amd64 / arm64）构建示例：

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t <你的镜像名>:latest --push .
```

## 文件说明

| 文件 | 作用 |
|---|---|
| `Dockerfile` | 镜像构建定义（含 config 合并阶段） |
| `docker-compose.yml` | 一键部署编排 |
| `.dockerignore` | 构建上下文排除项 |
| `httpd.conf` | BusyBox httpd MIME 补充（`.wasm` 等，镜像自动生效且禁止外部访问） |
| `config-docker.json` | **运行时配置覆盖层**，见下 |

## config-docker.json（配置覆盖，避免与上游冲突）

游戏运行时固定请求 `/config.json`，该文件由上游维护、更新频繁。为避免合并冲突，本 fork **不修改 git 中的 `config.json`**，而是把定制项写进 `config-docker.json`：Docker 构建时（`config` 阶段）将其**深度合并**到上游 `config.json` 之上，仅覆盖其中出现的键，其余键随上游自动更新。

当前内容为空覆盖 `{}`（行为与上游完全一致）。

**设计决策：不集成游戏资源文件。** 游戏完全体资源（`full-pack.7z` 等）与游戏版本强绑定且更新频繁，打包进镜像会带来版本错配风险；本 fork 保持镜像轻量（约 75MB），资源由玩家首次游戏时按官方地址下载，始终与游戏版本自动匹配，兼容性最佳。

如确有需要（如内网离线环境），也可通过覆盖层把资源地址指向本地（需自行在镜像中放置对应资源文件，并注意版本匹配）：

```json
{
  "gameResArchiveUrl": "/res/full-pack.7z"
}
```

## 同步上游

```bash
git remote add upstream https://github.com/ra2web/ra2web.github.io.git  # 一次性
git fetch upstream && git merge upstream/main
docker compose up -d --build
```

上述 Docker 相关文件均为本 fork 新增，上游不存在同名文件，合并不会被覆盖或产生冲突。
