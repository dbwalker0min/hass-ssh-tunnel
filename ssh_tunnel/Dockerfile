ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk update && apk add autossh bash

COPY run.sh /run.sh
COPY etc/services.d/ /etc/services.d/

# make sure the shell scripts are executable
RUN chmod +x /run.sh /etc/services.d/ssh_tunnel/run

