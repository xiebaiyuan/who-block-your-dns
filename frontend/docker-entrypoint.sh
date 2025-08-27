#!/bin/sh
set -e

echo "Starting entrypoint script"
echo "BACKEND_URL=${BACKEND_URL}"

# 渲染 nginx 配置模板，将 BACKEND_URL 注入
if [ -f /etc/nginx/conf.d/default.conf.template ]; then
  echo "Template file exists"
  echo "Template content:"
  cat /etc/nginx/conf.d/default.conf.template
  echo "End of template content"
  
  echo "Rendering nginx config with BACKEND_URL=${BACKEND_URL}"
  
  # Use sed to replace the variable instead of envsubst
  sed "s|\${BACKEND_URL}|${BACKEND_URL}|g" /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
  
  echo "Generated config:"
  cat /etc/nginx/conf.d/default.conf
  echo "End of generated config"
  
  # Test nginx config
  echo "Testing nginx config:"
  nginx -t 2>&1 || echo "Nginx config test failed"
  echo "End of nginx config test"
else
  echo "Template file does not exist"
fi

# 启动 nginx
exec nginx -g 'daemon off;'
