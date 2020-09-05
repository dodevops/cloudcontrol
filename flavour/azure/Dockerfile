ARG AZURE_VERSION=latest
FROM mcr.microsoft.com/azure-cli:${AZURE_VERSION}

RUN apk add sudo bash curl dialog && \
    echo "cloudcontrol ALL=(root)NOPASSWD:/sbin/apk *" > /etc/sudoers.d/cloudcontrol && \
    echo "cloudcontrol ALL=(root)NOPASSWD:/usr/local/bin/az *" >> /etc/sudoers.d/cloudcontrol && \
    adduser -D cloudcontrol && \
    mkdir /home/cloudcontrol/bin && \
    chown cloudcontrol /home/cloudcontrol/bin

# Flavour

COPY flavour/azure/flavour /home/cloudcontrol/flavour
COPY flavour/azure/flavourinit.sh /home/cloudcontrol/bin/flavourinit.sh
RUN chmod +x /home/cloudcontrol/bin/flavourinit.sh

# Features

COPY feature /home/cloudcontrol/feature-installers
COPY assets/feature-installer.sh /

# CCC

COPY assets/ccc /home/cloudcontrol/bin/ccc
RUN chmod +x /home/cloudcontrol/bin/ccc

# Cloud control

COPY assets/cloudcontrol.sh /usr/local/bin/cloudcontrol
RUN chmod +x /usr/local/bin/cloudcontrol

# Chown

RUN chown cloudcontrol -R /home/cloudcontrol

USER cloudcontrol

ENTRYPOINT ["/usr/local/bin/cloudcontrol"]
CMD ["serve"]
