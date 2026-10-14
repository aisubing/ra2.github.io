# 网页红警（RA2WEB）Docker 镜像
# 原项目：https://github.com/aisubing/ra2.github.io
# 镜像构建参考：https://github.com/Firfr/red_alert
#
# 本地构建：
#   docker build -t ra2web:latest .
#
# 多架构构建并推送（amd64 / arm64）：
#   docker buildx build --platform linux/amd64,linux/arm64 -t <你的镜像名>:latest --push .

FROM lipanski/docker-static-website:2.6.0

LABEL org.opencontainers.image.title="ra2web" \
      org.opencontainers.image.description="网页红警（RA2WEB / 网页红井）静态站点" \
      org.opencontainers.image.source="https://github.com/aisubing/ra2.github.io"

COPY . /home/static/

EXPOSE 5157

ENTRYPOINT ["/busybox-httpd", "-f", "-v"]
CMD ["-p", "5157"]
