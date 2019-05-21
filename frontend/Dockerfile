FROM node:12-alpine AS builder
ARG API_SERVER=backend
ENV API_SERVER=$API_SERVER
RUN apk update && \
    apk add gettext

WORKDIR /frontend
COPY ./frontend /frontend
COPY ./template /template
RUN envsubst < /template/config_template.js > /frontend/src/common/config.js

RUN npm install
RUN npm run build

FROM nginx:1.16
COPY --from=builder /frontend/dist /usr/share/nginx/html