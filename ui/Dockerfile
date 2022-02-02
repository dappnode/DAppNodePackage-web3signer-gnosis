FROM node:14-alpine3.14 as build
WORKDIR /app
RUN apk update && apk add git && git clone https://github.com/joaquim-verges/eth2-keymanager-frontend.git
WORKDIR /app/eth2-keymanager-frontend
RUN yarn
RUN yarn run build

FROM nginx:1.21.6-alpine 
COPY --from=build /app/eth2-keymanager-frontend/build/ /usr/share/nginx/html/
EXPOSE 80