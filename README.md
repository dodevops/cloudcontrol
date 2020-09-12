# CloudControl ☁️ 🧰

The cloud engineer's toolbox.

## Introduction

*CloudControl* is a [Docker](https://docker.com) based configuration environment containing all the tools
required and configured to manage modern cloud infrastructures.

The toolbox comes in different "flavours" depending on what cloud you are working in.
Currently supported cloud flavours are:

* ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/dodevops/cloudcontrol-aws?sort&#x3D;semver) [AWS](https://hub.docker.com/r/dodevops/cloudcontrol-aws) (based on [amazon/aws-cli](https://hub.docker.com/r/amazon/aws-cli))
* ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/dodevops/cloudcontrol-azure?sort&#x3D;semver) [Azure](https://hub.docker.com/r/dodevops/cloudcontrol-azure) (based on [mcr.microsoft.com/azure-cli](https://hub.docker.com/_/microsoft-azure-cli))

Following features and tools are supported:

* 🐟 Fish Shell
* ⛵️ Helm
* ⌨️ kc Quick Kubernetes Context switch
* 🐳 Kubernetes
* 📦 Packer
* 👟 Run
* 📜 Stern
* 🌏 Terraform
* 🐗 Terragrunt
* 🕰 Timezone configuration
* 🌊 Velero
* 𝑉  Vim

## Table of contents

* [Usage](#usage)
* [FAQ](#faq)
* [Flavours](#flavours)
    * [aws](#aws)
    * [azure](#azure)
* [Features](#features)
    * [fish](#fish)
    * [helm](#helm)
    * [kc](#kc)
    * [kubernetes](#kubernetes)
    * [packer](#packer)
    * [run](#run)
    * [stern](#stern)
    * [terraform](#terraform)
    * [terragrunt](#terragrunt)
    * [timezone](#timezone)
    * [velero](#velero)
    * [vim](#vim)
* [Development](#development)
* [Building](#building)

## Usage

*CloudControl* can be used best with docker-compose. Check out the `sample` directory in a flavour for a sample
compose file and to convenience scripts. It includes a small web server written in Go and Vuejs-client dubbed
"CloudControlCenter", which is used as a status screen. It listens to port 8080 inside the container.

Copy the compose file and configure it to your needs. Check below for configuration options per flavour and feature.

Run `init.sh`. This script basically just runs `docker-compose up -d` and tells you the URL for CloudControlCenter.
Open it and wait for CloudControl to finish initializing.

The initialization process will download and configure the additional tools and completes with a message when its done.
It will run each time when the stack is recreated.

After the initialization process you can simply run `docker-compose exec cli /usr/local/bin/cloudcontrol run` to jump
into the running container and work with the installed features.

If you need to change any of the configuration environment variables, run `docker-compose up -d` afterwards to apply
the changes. Remember, that CloudControl needs to reininitialize for this.

## FAQ

### How can I add an informational text for users of CloudControl?

If you want to display a *custom login message* when users enter the container, set environment variable `MOTD`
to that message. If you want to display the default login message as well, also
set the environment variable `MOTD_DISPLAY_DEFAULT` to *yes*.

### How can I forward ports to the host?

If you'd like to forward traffic into a cluster using `kubectl port-forward` you can do the following:

* Add a ports key to the cli-service in your docker-compose file to forward a free port on your host to a defined
port in your container. The docker-compose-files in the sample directories already use port 8081 for this.

* Inside *CloudControl*, check the IP of the container:

```
bash-5.0$ ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:42:AC:15:00:02
          inet addr:172.21.0.2  Bcast:172.21.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:53813 errors:0 dropped:0 overruns:0 frame:0
          TX packets:20900 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:75260363 (71.7 MiB)  TX bytes:2691219 (2.5 MiB)
```

* Use the IP address used by the container as the bind address for port-forward to forward traffic
to the previously defined container port to a service on its port (e.g. port 8081 to the
service my-service listening on port 8080):

```
kubectl port-forward --address 172.21.0.2 svc/my-service 8081:8080
```

* Check out, which host port docker bound to the private port you set up (e.g. 8081)

```
docker-compose port cli 8081
```

* Connect to localhost:<host port> on your host

### How to set up command aliases

If you'd like to set up aliases to save some typing, you can use the *run* feature. Run your container with these
environment variables:

* `USE_run=yes`: Set up the run feature
* `RUN_COMMANDS=alias firstalias=command;alias secondalias=command`: Set up some aliases

## Flavours

### aws

Can be used to connect to infrastructure in the AWS cloud. Also see [the AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) for more configuration options


#### Configuration

* Environment AWS_ACCESS_KEY_ID: Specifies an AWS access key associated with an IAM user or role
* Environment AWS_SECRET_ACCESS_KEY: Specifies the secret key associated with the access key. This is essentially the password for the access key
* Environment AWS_DEFAULT_REGION: Specifies the AWS Region to send the request to
### azure

Can be used to connect to infrastructure in the Azure cloud. Because we&#x27;re using a container,
a device login will happen, requiring the user to go to a website, enter a code and login.
This only happens once during initialization phase.


#### Configuration

* Environment AZ_SUBSCRIPTION: The Azure subscription to use in this container

## Features

### fish

Installs and configures the [Fish Shell](https://fishshell.com/) with configured [Spacefish theme](https://spacefish.matchai.me/)

#### Configuration

* USE_fish: Enable this feature

### helm

Installs [Helm](https://helm.sh)

#### Configuration

* USE_helm: Enable this feature
* Environment HELM_VERSION: Valid Helm version to install (e.g. 1.5.4)

### kc

Installs [kc](https://github.com/dodevops/cloudcontrol/blob/master/feature/kc/kc.sh), a quick context switcher for kubernetes.


#### Configuration

* USE_kc: Enable this feature

### kubernetes

Installs and configures [kubernetes](https://kubernetes.io/docs/reference/kubectl/overview/) with [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) to connect to the flavour&#x27;s kubernetes clusters

#### Configuration

* USE_kubernetes: Enable this feature
* (azure flavour) Environment AZ_K8S_CLUSTERS: A comma separated list of AKS clusters to manage
inside *CloudControl* (only for azure flavour).
Each cluster is a pair of resource group and cluster name, separated by a colon.
For example: myresourcegroup:myk8s,myotherresourcegroup:mysecondk8s will install myk8s from
the myresourcegroup resource group and mysecondk8s from the resource group myotherresourcegroup.
Prefix a cluster name with an ! to load the admin-credentials for that cluster instead of the user credentials.

* (aws flavour) Environment AWS_K8S_CLUSTERS: A comma separated list of EKS clusters to manage
inside *CloudControl* (only for aws flavour).
For each cluster give the cluster name. If you need to assume an ARN role, add that to the clustername
with an additional | added.
For example: myekscluster|arn:aws:iam::32487234892:sample/sample

If you additionally need to assume a role before fetching the EKS credentials, add the role, prefixed with
an @:
myekscluster|arn:aws:iam::4327849324:sample/sample@arn:aws:iam::specialrole


### packer

Installs [Packer](https://packer.io)

#### Configuration

* USE_packer: Enable this feature
* Environment PACKER_VERSION: Valid Packer version to install (e.g. 1.5.4)

### run

Runs commands inside the shell when entering the cloud control container

#### Configuration

* USE_run: Enable this feature
* Environment RUN_COMMANDS: Valid shell commands to run

### stern

Installs [stern](https://github.com/wercker/stern), a multi pod and container log tailing for Kubernetes


#### Configuration

* USE_stern: Enable this feature
* Environment STERN_VERSION: Valid Stern version (e.g. 1.11.0)

### terraform

Installs and configures [Terraform](https://terraform.io)

#### Configuration

* USE_terraform: Enable this feature
* Volume-target /terraform: Your local terraform base directory
* Volume-target /credentials.terraform: A Terraform variable file holding sensitive information when working with terraform (e.g. Terraform app secrets, etc.)
* Environment TERRAFORM_VERSION: A valid terraform version to install (e.g. 0.12.17)

### terragrunt

Installs [Terragrunt](https://github.com/gruntwork-io/terragrunt)

#### Configuration

* USE_terragrunt: Enable this feature
* Environment TERRAGRUNT_VERSION: Valid version of terragrunt to install

### timezone

Configures the container&#x27;s timezone

#### Configuration

* USE_timezone: Enable this feature
* Environment TZ: The timezone to use

### velero

Installs the [Velero](https://velero.io) kubernetes backup CLI

#### Configuration

* USE_velero: Enable this feature
* Environment VELERO_VERSION: Valid velero version to install (e.g. v1.4.2)

### vim

Installs [Vim](https://www.vim.org/)

#### Configuration

* USE_vim: Enable this feature


## Development

*CloudControl* supports a decoupled development of features and flavours. If you're missing something, just fork this
repository, create a subfolder for your new feature under "features" and add these files:

* feature.yaml: A descriptor for your feature with a title, a description and configuration notes
* install.sh: A shell script that is run by CloudControlCenter and should install everything you need
  for your new feature
* motd.sh: (optional) If you want to show some information to the users upon login, put them here.

If you need another flavour (aka cloud provider), add a new subdirectory under "flavour" and add a flavour.yaml describing
your flavour the same way as a feature. For the rest of the files, please check out existing flavours for details. Please,
include a sample configuration for your flavour to make it easier for other people to work with it.

## Building

Build a flavor container image with the base of the repository as the build context like this:

    build.sh <tag> <flavour>

To build all flavours with the same tag, use

    build.sh <tag>
