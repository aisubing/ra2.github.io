# 网页红警（RA2WEB）Docker 镜像
# 原项目：https://github.com/aisubing/ra2.github.io
# 镜像构建参考：https://github.com/Firfr/red_alert
#
# 本地构建：
#   docker build -t ra2web:latest .
#
# 多架构构建并推送（amd64 / arm64）：
#   docker buildx build --platform linux/amd64,linux/arm64 -t <你的镜像名>:latest --push .

# 配置合并阶段：把 config-docker.json（本 fork 的覆盖层）深度合并到上游 config.json 之上。
# git 中的 config.json 与上游保持一致，定制只写入 config-docker.json，同步上游零冲突；
# 上游新增的配置键也会自动带入（只覆盖覆盖层中出现的键）。
FROM python:3.13-alpine AS config
WORKDIR /src
COPY config.json config-docker.json ./
RUN python - <<'EOF'
import json
base = json.load(open('config.json'))
over = json.load(open('config-docker.json'))
def deep(b, o):
    for k, v in o.items():
        if isinstance(v, dict) and isinstance(b.get(k), dict):
            deep(b[k], v)
        else:
            b[k] = v
deep(base, over)
json.dump(base, open('config.json', 'w'), ensure_ascii=False, indent=2)
print('config 覆盖层:', over if over else '(空，保持上游原样)')
EOF

FROM lipanski/docker-static-website:2.6.0

# 镜像版本标签：CI 从 version.json 的 appVersion 自动传入；本地构建默认 dev。
# 查看方式：docker inspect --format '{{ index .Config.Labels "org.opencontainers.image.version" }}' <镜像>
ARG RA2WEB_VERSION=dev

LABEL org.opencontainers.image.title="ra2web" \
      org.opencontainers.image.description="网页红警（RA2WEB / 网页红井）静态站点" \
      org.opencontainers.image.source="https://github.com/aisubing/ra2.github.io" \
      org.opencontainers.image.version=$RA2WEB_VERSION

COPY . /home/static/
COPY --from=config /src/config.json /home/static/config.json

EXPOSE 5157

ENTRYPOINT ["/busybox-httpd", "-f", "-v"]
CMD ["-p", "5157"]
