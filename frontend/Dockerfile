FROM nginx:alpine

# Frontend Dockerfile - 基于 Nginx 的静态文件服务器

# 复制静态文件到 nginx 默认目录
COPY . /usr/share/nginx/html

# 复制 nginx 配置模板和启动脚本
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template
COPY docker-entrypoint.sh /docker-entrypoint.sh

# 在 alpine 中安装 envsubst（来自 gettext）用于渲染模板
RUN apk add --no-cache gettext \
    && chmod +x /docker-entrypoint.sh

# 默认后端地址（可在运行容器时通过环境变量覆盖）
ENV BACKEND_URL=http://backend:8080

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]