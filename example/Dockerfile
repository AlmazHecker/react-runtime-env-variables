FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
COPY package-lock.json ./
RUN npm install

COPY .. .
RUN npm run build:docker

FROM nginx:stable-perl

COPY --from=build /app/dist /usr/share/nginx/html
COPY --from=build /app/predeploy.sh /usr/share/nginx/html

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

RUN chmod +x /usr/share/nginx/html/predeploy.sh

CMD /usr/share/nginx/html/predeploy.sh
