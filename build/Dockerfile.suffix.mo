# Features

COPY feature /home/cloudcontrol/feature-installers
COPY assets/feature-installer-utils.sh /

# CCC

COPY --from=cccBuild /build/ccc /usr/local/ccc/ccc
RUN chmod +x /usr/local/ccc/ccc

COPY --from=cccClientBuild /build/dist /usr/local/ccc/client

# Cloud control

COPY assets/cloudcontrol.sh /usr/local/bin/cloudcontrol
RUN chmod +x /usr/local/bin/cloudcontrol

# Chown

RUN chown cloudcontrol -R /home/cloudcontrol

EXPOSE 8080
USER cloudcontrol
ENTRYPOINT ["/usr/local/bin/cloudcontrol"]
WORKDIR /home/cloudcontrol
CMD ["serve"]

# Labels

LABEL io.artifacthub.package.readme-url=https://github.com/dodevops/cloudcontrol
LABEL org.opencontainers.image.created={{BUILD_DATE}}
LABEL org.opencontainers.image.description="The cloud engineer's toolbox - {{FLAVOUR}} flavour"
LABEL org.opencontainers.image.documentation=https://github.com/dodevops/cloudcontrol
LABEL org.opencontainers.image.source=https://github.com/dodevops/cloudcontrol
LABEL org.opencontainers.image.title="cloudcontrol-{{FLAVOUR}}"
LABEL org.opencontainers.image.url=https://github.com/dodevops/cloudcontrol
LABEL org.opencontainers.image.vendor="DO! DevOps"