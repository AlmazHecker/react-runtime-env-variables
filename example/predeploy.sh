#!/bin/sh

echo "current ENVIRONMENT: $ENVIRONMENT"

if [ "$ENVIRONMENT" = "prod" ]; then
    # Replace DOCKER_BACKEND_URL with production URL
    find /usr/share/nginx/html -type f -exec sed -i 's|DOCKER_BACKEND_URL|https://prod.backend.com|g' {} +
else
    # Replace DOCKER_BACKEND_URL with development URL by default
    find /usr/share/nginx/html -type f -exec sed -i 's|DOCKER_BACKEND_URL|https://dev.backend.com|g' {} +
fi

echo "ENV variables set!"


nginx -g "daemon off;"