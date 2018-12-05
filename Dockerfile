FROM alpine:3.8

RUN apk add --no-cache curl jq bash

ADD scripts/run.sh /bin/plugin/run.sh
RUN chmod +x /bin/plugin/*

WORKDIR /app

ENTRYPOINT /bin/plugin/run.sh