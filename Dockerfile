FROM node:9-alpine

LABEL maintainer="Yago Toledo Lima <yagotoledolima@gmail.com>"

RUN apk update\
      && apk add tzdata

WORKDIR /app

COPY bin bin
COPY scripts scripts
COPY package.json external-scripts.json hubot-scripts.json hubot-slack-token.env ./

ENTRYPOINT ["./bin/docker-entrypoint.sh"]
