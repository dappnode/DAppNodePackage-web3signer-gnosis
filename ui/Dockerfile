FROM node:14-alpine3.14 as build
ENV REACT_APP_NETWORK=gnosis
WORKDIR /app
RUN apk update && apk add git && git clone https://github.com/dappnode/eth2-keymanager-frontend-dappnode-temporary.git
WORKDIR /app/eth2-keymanager-frontend-dappnode-temporary
RUN npm install --globally react-scripts
RUN yarn
RUN yarn run build

FROM nginx:1.21.6-alpine
COPY --from=build /app/eth2-keymanager-frontend-dappnode-temporary/build/ /usr/share/nginx/html/
EXPOSE 80
