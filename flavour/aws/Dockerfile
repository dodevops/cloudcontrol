ARG AWS_VERSION=latest
FROM amazon/aws-cli:${AWS_VERSION}

COPY flavour/aws/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

RUN yum install -y sudo shadow-utils && \
    echo "cloudcontrol ALL=(root)NOPASSWD:/usr/bin/yum *" > /etc/sudoers.d/cloudcontrol && \
    echo "cloudcontrol ALL=(root)NOPASSWD:/usr/bin/tee *" >> /etc/sudoers.d/cloudcontrol && \
    adduser cloudcontrol && \
    mkdir /home/cloudcontrol/bin && \
    chown cloudcontrol /home/cloudcontrol/bin

# AWS Sudo

RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash - && \
    yum install -y nodejs && \
    npm install -g awsudo

# Features

COPY feature /home/cloudcontrol/feature-installers
COPY assets/feature-installer.sh /

# Cloud control

COPY assets/cloud-control.sh /usr/local/bin/cloud-control
RUN chmod +x /usr/local/bin/cloud-control

RUN yum install -y unzip tar

USER cloudcontrol

ENTRYPOINT /docker-entrypoint.sh
