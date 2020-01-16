FROM node:8-slim as builder

RUN apt-get update && apt-get install -y curl build-essential libzmq3-dev python

RUN npm init -y && npm i bitcore
RUN sed -i -e "s/'use strict';.*/'use strict';\nObject.defineProperty(global, '_bitcore', { get(){ return undefined }, set(){} });/g" ./node_modules/bitcore/bin/bitcored

# Actual image
FROM node:8-slim

RUN apt-get update && apt-get install -y libzmq3-dev

COPY --from=builder /node_modules /node_modules
COPY ./bitcore-node.json /.bitcore/bitcore-node.json

VOLUME ["/.bitcore/data"]
EXPOSE 3001

CMD ["/node_modules/bitcore/bin/bitcored", "-c", "/.bitcore/bitcore-node.json"]
