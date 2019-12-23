ARG AZURE_VERSION=latest
FROM mcr.microsoft.com/azure-cli:${AZURE_VERSION}

COPY flavour/azure/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

RUN apk add sudo && \
    echo "cloudcontrol ALL=(root)NOPASSWD:/sbin/apk *" > /etc/sudoers.d/cloudcontrol && \
    echo "cloudcontrol ALL=(root)NOPASSWD:/usr/local/bin/az *" >> /etc/sudoers.d/cloudcontrol && \
    adduser -D cloudcontrol && \
    mkdir /home/cloudcontrol/bin && \
    chown cloudcontrol /home/cloudcontrol/bin

# Features

COPY feature /home/cloudcontrol/feature-installers
COPY assets/feature-installer.sh /

# Cloud control

COPY assets/cloud-control.sh /usr/local/bin/cloud-control
RUN chmod +x /usr/local/bin/cloud-control

RUN apk add bash curl

USER cloudcontrol

ENTRYPOINT /docker-entrypoint.sh
