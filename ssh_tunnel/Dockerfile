ARG BUILD_FROM
FROM $BUILD_FROM
#FROM ghcr.io/home-assistant/amd64-base:latest

RUN apk update && apk add autossh bash

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
