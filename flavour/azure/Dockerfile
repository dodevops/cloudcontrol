ARG AZURE_VERSION=latest
FROM mcr.microsoft.com/azure-cli:${AZURE_VERSION}

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

RUN apk add sudo && \
    echo "cloudcontrol ALL=(ALL) NOPASSWD: apk" > /etc/sudoers.d/cloudcontrol && \
    echo "cloudcontrol ALL=(ALL) NOPASSWD: az" > /etc/sudoers.d/cloudcontrol && \
    adduser -D cloudcontrol && \
    mkdir /home/cloudcontrol/bin && \
    chown cloudcontrol /home/cloudcontrol/bin

# Tools

COPY assets /home/cloudcontrol/assets

# Features

COPY features /home/cloudcontrol/features-installers

# Cloud control

COPY cloud-control.sh /usr/local/bin/cloud-control
RUN chmod +x /usr/local/bin/cloud-control

RUN apk add bash dialog curl

USER cloudcontrol

ENTRYPOINT /docker-entrypoint.sh
