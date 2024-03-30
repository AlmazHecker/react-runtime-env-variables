
# React runtime env variables script

If you have a project with multiple runtimes (such as development, staging, production, etc.) or if you are building a SaaS (Software as a Service) project, you will need to access runtime variables to set some default settings.

In my case, it was a Dockerized application with two environments, each using the same build step - meaning the same Dockerfile for both environments.

## The Idea
The idea is to replace all occurrences of environment variables after the bundle is generated.

## 1. Create env file for docker
Create .env.docker file and specify in it all the variables that are dynamic.
For example:

for CRA:
```
REACT_APP_BACKEND_URL=DOCKER_BACKEND_URL 
```
for Vite:
```
VITE_APP_BACKEND_URL=DOCKER_BACKEND_URL
```
Note: The values of the environment variables shouldn't duplicate or match the project code; otherwise, your app will fail to start


## 2. Add a new script for Docker to package.json
This script will build your app with .env.docker variables

Vite:
```json
"build:docker": "tsc && vite build --mode docker",
```
CRA  (you will need to install an additional package, env-cmd):
```json
"start:staging": "env-cmd -f .env.docker react-scripts start",
```

## 3. Update Dockerfile
```dockerfile
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
COPY package-lock.json ./
RUN npm install

COPY . .
RUN npm run build:docker

FROM nginx:stable-perl

COPY --from=build /app/dist /usr/share/nginx/html
COPY --from=build /app/predeploy.sh /usr/share/nginx/html

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

RUN chmod +x /usr/share/nginx/html/predeploy.sh

CMD /usr/share/nginx/html/predeploy.sh
```

Note: If you have a different Dockerfile, the main updates you should make are:

- Replace the "npm run build" instruction with "npm run build:docker".
- Copy predeploy.sh to /usr/share/nginx/html and give it permissions to run.
- Ensure that the project code is at the same level as the predeploy.sh script.

## 4. Create SH script
Place it at the root dir of your project and name it "predeploy.sh"
This is the script that will search and replace env variables.

```sh
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
```

In my case, there was a $ENVIRONMENT runtime variable that indicated whether the environment was production or development, and based on its value, I hardcoded the backend URL.

If you have a dynamic runtime environment variable (such as $BACKEND_URL, for example), you can set it like this:

```sh
find /usr/share/nginx/html -type f -exec sed -i 's|DOCKER_BACKEND_URL|$BACKEND_URL|g' {} +
```

P.S. You can find an example of usage in the 'example' directory