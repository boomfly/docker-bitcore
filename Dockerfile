FROM node:8-slim as builder

RUN apt-get update && apt-get install -y curl build-essential libzmq3-dev python

RUN npm init -y && npm i bitcore
RUN sed -i -e "s/'use strict';.*/'use strict';\nObject.defineProperty(global, '_bitcore', { get(){ return undefined }, set(){} });/g" ./node_modules/bitcore/bin/bitcored
RUN sed -i -e "s/var pageLength = 10.*/var pageLength = 100/g" ./node_modules/insight-api/lib/transactions.js

# Actual image
FROM node:8-slim

LABEL maintainer="boomfly@rambler.ru"
LABEL description="bitcore@4.1.1 image"

RUN apt-get update && apt-get install -y libzmq3-dev

COPY --from=builder /node_modules /node_modules
COPY ./bitcore-node.json /.bitcore/bitcore-node.json

VOLUME ["/.bitcore/data"]
EXPOSE 3001

CMD ["/node_modules/bitcore/bin/bitcored", "-c", "/.bitcore/bitcore-node.json"]
