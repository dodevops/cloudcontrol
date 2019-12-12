ARG AZURE_VERSION=latest
FROM mcr.microsoft.com/azure-cli:${AZURE_VERSION}

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Tools

COPY tools/kc.sh /usr/local/bin/kc
RUN chmod +x /usr/local/bin/kc

# Cloud control

COPY cloud-control.sh /usr/local/bin/cloud-control
RUN chmod +x /usr/local/bin/cloud-control

RUN apk add bash dialog curl
COPY tools/spacefish.fish /root/spacefish.fish

ENTRYPOINT /docker-entrypoint.sh
