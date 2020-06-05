# CloudControl ☁️ 🧰

The cloud engineer's toolbox.

## Introduction

*CloudControl* is a [Docker](https://docker.com) based configuration environment containing all the tools required and configured to manage modern cloud infrastructures.

The toolbox comes in cloud flavors. Currently supported cloud flavours are

* [![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/dodevops/cloudcontrol-aws)](https://hub.docker.com/r/dodevops/cloudcontrol-aws) AWS (based on [amazon/aws-cli](https://hub.docker.com/r/amazon/aws-cli))
* [![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/dodevops/cloudcontrol-azure)](https://hub.docker.com/r/dodevops/cloudcontrol-azure) Azure (based on [mcr.microsoft.com/azure-cli](https://hub.docker.com/_/microsoft-azure-cli))

Following features and tools are supported:

* 🐟 [Fish Shell](https://fishshell.com/) with configured [Spacefish theme](https://spacefish.matchai.me/)
* 🚢 [Helm](https://helm.sh)
* [kc Quick Kubernetes Context switch](https://github.com/dodevops/cloudcontrol/blob/master/feature/kc/kc.sh)
* 🐳 [kubernetes](https://kubernetes.io/docs/reference/kubectl/overview/)
* 📦 [Packer](https://packer.io/)
* ⎈ [Stern - Multi pod and container log tailing for Kubernetes](https://github.com/wercker/stern)
* 🌏 [Terraform](https://terraform.io)
* 🐗 [Terragrunt](https://github.com/gruntwork-io/terragrunt)
* 🕰 Timezone configuration
* 𝑉 [Vim](https://www.vim.org/)

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
    * [stern](#stern)
    * [terraform](#terraform)
    * [terragrunt](#terragrunt)
    * [timezone](#timezone)
    * [vim](#vim)
* [Development](#development)
* [Building](#building)

## Usage

*CloudControl* can be used best with docker-compose. Check out the `sample` directory in a flavour for a sample
compose file and to convenience scripts.

Copy the compose file and configure it to your needs. Check below for configuration options per flavour and feature.

Run `init.sh`. This script basically just runs `docker-compose up -d` and immediately calls
`docker-compose logs -f cli` afterwards to start the stack and show the logs of the initialization process.

The initialization process will download and configure the additional tools and completes with a message when its done.
It will run each time when the stack is recreated.

After the initialization process you can simply run `run.sh` or `docker-compose exec cli cloud-control` to jump into
the running container and work with the installed features.

If you want to display a *custom login message* when users enter the container, set then environment variable `MOTD`
to that message. If you want to display the default login message as well, also
set the environment variable `MOTD_DISPLAY_DEFAULT` to *yes*.

## FAQ

### How to forward ports to the host

If you'd like to forward traffic into a cluster using `kubectl port-forward` you can do the following:

* Add a ports key to the cli-service in your docker-compose file to forward a free port (e.g. 8888):

```
ports:
  - "8888:8888"
```

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

* Use the IP address used by the container as the bind address to forward traffic of the my-service service on port 8080:

```
kubectl port-forward --address 172.21.0.2 svc/my-service 8888:8080
```

* Connect to localhost:8888 on your host

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

Installs and configures the fish shell

#### Configuration

* USE_fish: Enable this feature

### helm

Installs [Helm](https://helm.sh)

#### Configuration

* USE_helm: Enable this feature
* Environment HELM_VERSION: Valid Helm version to install (e.g. 1.5.4)

### kc

Installs a quick context switcher for kubernetes.

Run kc to select the current working context for kubectl commands.
Run kc -n to switch the namespace in the current context.


#### Configuration

* USE_kc: Enable this feature

### kubernetes

Installs and configures [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) to connect to the flavour&#x27;s kubernetes clusters

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


### packer

Installs [Packer](https://packer.io)

#### Configuration

* USE_packer: Enable this feature
* Environment PACKER_VERSION: Valid Packer version to install (e.g. 1.5.4)

### stern

Installs [stern](https://github.com/wercker/stern).


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

### vim

Installs [Vim](https://www.vim.org/)

#### Configuration

* USE_vim: Enable this feature


## Development

*CloudControl* supports a decoupled development of features and flavours. If you're missing something, just fork this
repository, create a subfolder for your new feature under "features" and add two files:

* feature.yaml: A descriptor for your feature with a title, a description and configuration notes
* feature.sh: A shell script that is run by the cloud control entrypoint script and should install everything you need
  for your new feature
* motd.sh: (optional) If you want to show some information to the users upon login, put them here.

If you need another flavour (aka cloud provider), add a new subdirectory under "flavour" and add a flavour.yaml describing
your flavour the same way as a feature. For the rest of the files, please check out existing flavours for details. Please,
include a sample configuration for your flavour to make it easier for other people to work with it.

## Building

Build a flavor container image with the base of the repository as the build context like this:

    docker build -f flavour/azure/Dockerfile .
