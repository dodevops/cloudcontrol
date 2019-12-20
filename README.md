# CloudControl ☁️ 🧰

The cloud engineer's toolbox.

## Introduction

*CloudControl* is a [Docker](https://docker.com) based configuration environment containing all the tools required and configured to manage modern cloud infrastructures.

The toolbox comes in cloud flavors. Currently supported cloud flavours are

* [![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/dodevops/cloudcontrol-azure)](https://hub.docker.com/r/dodevops/cloudcontrol-azure) Azure (based on [mcr.microsoft.com/azure-cli](https://hub.docker.com/_/microsoft-azure-cli))

Following features and tools are supported:

* 🐟 [Fish Shell](https://fishshell.com/) with configured [Spacefish theme](https://spacefish.matchai.me/)
* 🚢 [Helm](https://helm.sh)
* [kc Quick Kubernetes Context switch](https://github.com/dodevops/cloudcontrol/blob/master/feature/kc/kc.sh)
* 🐳 [kubernetes](https://kubernetes.io/docs/reference/kubectl/overview/)
* 🌏 [Terraform](https://terraform.io)
* 🐗 [Terragrunt](https://github.com/gruntwork-io/terragrunt)

## Usage

*CloudControl* can be used best with docker-compose. Check out the `sample` directory in a flavour for a sample compose file and to convenience scripts.

Copy the compose file and configure it to your needs. Check below for configuration options per flavour and feature.

Run `init.sh`. This script basically just runs `docker-compose up -d` and immediately calls `docker-compose logs -f cli` afterwards to start the stack and show the logs of the initialization process.

The initialization process will download and configure the additional tools and completes with a message when its done. It will run each time when the stack is recreated.

After the initialization process you can simply run `run.sh` or `docker-compose exec cli cloud-control` to jump into the running container and work with the installed features.

## Flavours

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
* Environment HELM_VERSION: Valid Helm version to install (e.g. 2.16.1)

### kc

Installs a quick context switcher for kubernetes

#### Configuration

* USE_kc: Enable this feature
* Environment USE_KC: Enable kc feature

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


## Development

*CloudControl* supports a decoupled development of features and flavours. If you're missing something, just fork this
repository, create a subfolder for your new feature under "features" and add two files:

* feature.yaml: A descriptor for your feature with a title, a description and configuration notes
* feature.sh: A shell script that is run by the cloud control entrypoint script and should install everything you need
  for your new feature

If you need another flavour (aka cloud provider), add a new subdirectory under "flavour" and add a flavour.yaml describing
your flavour the same way as a feature. For the rest of the files, please check out existing flavours for details. Please,
include a sample configuration for your flavour to make it easier for other people to work with it.

## Building

Build a flavor container image with the base of the repository as the build context like this:

    docker build -f flavour/azure/Dockerfile .
