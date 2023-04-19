# CloudControl ☁️ 🧰

The cloud engineer's toolbox.

## Introduction

*CloudControl* is a [Docker](https://docker.com) based configuration environment containing all the tools
required and configured to manage modern cloud infrastructures.

The toolbox comes in different "flavours" depending on what cloud you are working in.
Currently supported cloud flavours are:
* ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/dodevops/cloudcontrol-aws?sort=semver) [AWS](https://hub.docker.com/r/dodevops/cloudcontrol-aws) (based on [amazon/aws-cli](https://hub.docker.com/r/amazon/aws-cli))
* ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/dodevops/cloudcontrol-azure?sort=semver) [Azure](https://hub.docker.com/r/dodevops/cloudcontrol-azure) (based on [mcr.microsoft.com/azure-cli](https://hub.docker.com/_/microsoft-azure-cli))
* ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/dodevops/cloudcontrol-gcloud?sort=semver) [Google Cloud](https://hub.docker.com/r/dodevops/cloudcontrol-gcloud) (based on [google-cloud-cli](https://console.cloud.google.com/gcr/images/google.com:cloudsdktool/GLOBAL/google-cloud-cli))
* ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/dodevops/cloudcontrol-simple?sort=semver) [Simple](https://hub.docker.com/r/dodevops/cloudcontrol-simple) (based on [alpine](https://hub.docker.com/_/alpine))
* ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/dodevops/cloudcontrol-tanzu?sort=semver) [Tanzu](https://hub.docker.com/r/dodevops/cloudcontrol-tanzu) (based on [alpine](https://hub.docker.com/_/alpine))

Following features and tools are supported:
* 🐟 Fish Shell
* 📷 AzCopy
* 🔐 Bitwarden
* 🪪 Certificates
* ⚙️ Direnv
* 🔥 Git
* ⛵️ Helm
* 🛠 JQ
* ⌨️ kc Quick Kubernetes Context switch
* 🐚 Kubectlnodeshell
* 🐳 Kubernetes
* 📦 Packages
* 📦 Packer
* 👟 Run
* 📜 Stern
* 🌏 Terraform
* 🐗 Terragrunt
* 🕰 Timezone configuration
* 🌊 Velero
* 𝑉 Vim
* 🛠 YQ

## Table of contents

* [Usage](#usage)
* [Using Kubernetes](#using-kubernetes-preview)
* [FAQ](#faq)
* [Flavours](#flavours)
    * [aws](#aws)
    * [azure](#azure)
    * [gcloud](#gcloud)
    * [simple](#simple)
    * [tanzu](#tanzu)
* [Features](#features)
    * [Fish Shell](#_fish)
    * [AzCopy](#azcopy)
    * [Bitwarden](#bitwarden)
    * [Certificates](#certificates)
    * [Direnv](#direnv)
    * [Git](#git)
    * [Helm](#helm)
    * [JQ](#jq)
    * [kc Quick Kubernetes Context switch](#kc)
    * [Kubectlnodeshell](#kubectlnodeshell)
    * [Kubernetes](#kubernetes)
    * [Packages](#packages)
    * [Packer](#packer)
    * [Run](#run)
    * [Stern](#stern)
    * [Terraform](#terraform)
    * [Terragrunt](#terragrunt)
    * [Timezone configuration](#timezone)
    * [Velero](#velero)
    * [Vim](#vim)
    * [YQ](#yq)
* [Development](#development)
* [Building](#building)

## Usage

*CloudControl* can be used best with docker-compose. Check out the `sample` directory in a flavour for a sample
compose file and to convenience scripts. It includes a small web server written in Go and Vuejs-client dubbed
"CloudControlCenter", which is used as a status screen. It listens to port 8080 inside the container.

Copy the compose file and configure it to your needs. Check below for configuration options per flavour and feature.

Run `init.sh`. This script basically just runs `docker-compose up -d` and tells you the URL for CloudControlCenter.
Open it and wait for *CloudControl* to finish initializing.

The initialization process will download and configure the additional tools and completes with a message when its done.
It will run each time when the stack is recreated.

After the initialization process you can simply run `docker-compose exec cli /usr/local/bin/cloudcontrol run` to jump
into the running container and work with the installed features.

If you need to change any of the configuration environment variables, rerun the init script afterwards to apply
the changes. Remember, that *CloudControl* needs to reininitialize for this.

## Configuring features

There are two ways to configure a feature and the version it should use. The first way is to use the given
`USE_[feature name]=yes` environment variable and specifying the version with `[FEATURE NAME]_VERSION=[version]`.

If there are multiple features configured, this can get a bit messy. Another approach is to use the `FEATURES`
environment variable and list the features and optionally the version like this:

    FEATURES=kubernetes helm:3.5.1 terraform:1.1.9

This would install the version 3.5.1 of Helm and version 1.1.9 of terraform. (Kubernetes uses the flavour's provided
version of kubectl, e.g. using az aks install-cli)

**Note**: Please see the feature documentation below if a feature supports specifying a version string. All version
strings need to be provided in semver format (f.e. 1.2.3), the feature installers will take care about prefixes for
download URLs, if required.

## Using Kubernetes (Preview)

*CloudControl* is targeted to run on a local machine. It requires the following features to work:

* host path volumes
* host based networking

Some Kubernetes distributions such as [Rancher desktop](https://rancherdesktop.io/) support this and can be used to
run *CloudControl*.

The `sample` directories of each flavour provide an example Kubernetes configuration based on a deployment and a
service. They were preliminary tested on Rancher desktop.

Modify them to your local requirements and then run

    kubectl apply -f k8s.yaml

to apply them.

This will create a new namespace for your project and a deployment and a service in that. Check
`kubectl get -n [project] pod` to watch the progress until a cli pod has been created.

Use `kubectl get -n [project] svc cli` to see the bound ports for the cli service and use your browser to connect
to the *CloudControlCenter* instance.

After the initialization is done, use `kubectl -n [project] exec -it deployment/cli -- /usr/local/bin/cloudcontrol run`
to enter *CloudControl*.

*Warning*: This implementation is currently a preview feature and hasn't been tested thoroughly. It highly depends on
the proper support for host based volumes and networking of the Kubernetes distribution. Please refer to the
documentation and support of your Kubernetes distribution if something isn't working.

## FAQ

### How can I add an informational text for users of *CloudControl*?

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

* Connect to localhost:[host port] on your host

### How to set up command aliases

If you'd like to set up aliases to save some typing, you can use the *run* feature. Run your container with these
environment variables:

* `USE_run=yes`: Set up the run feature
* `RUN_COMMANDS=alias firstalias=command;alias secondalias=command`: Set up some aliases

### How can I share my SSH-keys with the *CloudControl* container

First, mount your .ssh directory into the container at /home/cloudcontrol/.ssh.

Also, to not enter your passphrase every time you use the key, you should mount the ssh agent socket into the
container and set the environment variable SSH_AUTH_SOCK to that path. *CloudControl* will automatically fix the
permissions of that file so the *CloudControl* user can use it.

Here are snippets for your docker-compose file for convenience:

    (...)
    volumes:
        - "[Path to .ssh directory]:/home/cloudcontrol/.ssh"
        # for Linux:
        - "${SSH_AUTH_SOCK}:/ssh-agent"
        # for macOS:
        - "/run/host-services/ssh-auth.sock:/ssh-agent"
    environment:
        - "SSH_AUTH_SOCK=/ssh-agent"

### How to identify Terraform state locks by other *CloudControl*-users

Because of how *CloudControl* is designed it uses a defined user named "cloudcontrol", so Terraform state lock
messages look like this:

> Error: Error locking state: Error acquiring the state lock: storage: service returned error: StatusCode=409, ErrorCode=LeaseAlreadyPresent, ErrorMessage=There is already a lease present.
  RequestId:56c21b95-501e-0096-7082-41fa0d000000
  Time:2021-05-05T07:41:25.9164547Z, RequestInitiated=Wed, 05 May 2021 07:41:25 GMT, RequestId=56c21b95-501e-0096-7082-41fa0d000000, API Version=2018-03-28, QueryParameterName=, QueryParameterValue=
  Lock Info:
  ID:        a1cef2cc-fec4-1765-4da8-d068a729ba7e
  Path:      path/terraform.tfstate
  Operation: OperationTypeApply
  Who:       cloudcontrol@5c47a37f920b
  Version:   0.12.17
  Created:   2021-05-05 07:38:01.188897776 +0000 UTC
  Info:

It's hard to identify from that who the other *CloudControl* user is, that may have opened a lock. The system
user can't be changed, but it's possible to set a better hostname than the one Docker autogenerated.

See this docker-compose snippet on how to set a better hostname:

    version: "3"
    services:
    cli:
    image: "dodevops/cloudcontrol-azure:latest"
    hostname: "[TODO yourname]"
    volumes:
    (...)

If you set hostname in that snippet to "alice", the state lock will look like this now:

> Error: Error locking state: Error acquiring the state lock: storage: service returned error: StatusCode=409, ErrorCode=LeaseAlreadyPresent, ErrorMessage=There is already a lease present.
  RequestId:56c21b95-501e-0096-7082-41fa0d000000
  Time:2021-05-05T07:41:25.9164547Z, RequestInitiated=Wed, 05 May 2021 07:41:25 GMT, RequestId=56c21b95-501e-0096-7082-41fa0d000000, API Version=2018-03-28, QueryParameterName=, QueryParameterValue=
  Lock Info:
  ID:        a1cef2cc-fec4-1765-4da8-d068a729ba7e
  Path:      path/terraform.tfstate
  Operation: OperationTypeApply
  Who:       cloudcontrol@alice
  Version:   0.12.17
  Created:   2021-05-05 07:38:01.188897776 +0000 UTC
  Info:

### I get an error "repomd.xml signature could not be verified for kubernetes" when using Kubernetes in the AWS flavour

*CloudControl* uses the
[official guide to install kubectl on an RPM-based system](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/).
However, Google seems to
[regularly have problems with its key-signing in the used repository](https://github.com/kubernetes/kubernetes/issues/60134),
so we added a workaround to this problem. If you add the environment variable `AWS_SKIP_GPG=1` to your
docker-compose.yaml, it will ignore an invalid GPG key during the installation.

*Please note though*, that this affects the security of the system and should not be used constantly.

### When I try to start *CloudControl*, it keeps exiting with "./ccc: exit status 1". What can I do?

Use the `docker logs` command with the failed container to see the complete log output. You can enhance the log by using the
"DEBUG_[feature]" options or add the environment variable "DEBUG_FLAVOUR" to turn on the debug log for the flavour
installation.

If you are really stuck, you can convince the container to keep running by setting "CONTINUE_ON_ERROR=yes" as an
environment variable in the docker-compose file. Then you can debug with the running container.

## Flavours

### <a id="aws"></a> aws

Can be used to connect to infrastructure in the AWS cloud. Also see [the AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) for more configuration options.
If you have activated MFA, set AWS_MFA_ARN to the ARN of your MFA device so CloudControl will ask you
for your code.
To start a new session in the CloudControl context, run `createSession <token>` afterwards

#### Configuration

* Environment AWS_ACCESS_KEY_ID: Specifies an AWS access key associated with an IAM user or role
* Environment AWS_SECRET_ACCESS_KEY: Specifies the secret key associated with the access key. This is essentially the password for the access key
* Environment AWS_DEFAULT_REGION: Specifies the AWS Region to send the request to
* Environment AWS_MFA_ARN: ARN of the MFA device to use to log in

### <a id="azure"></a> azure

Can be used to connect to infrastructure in the Azure cloud. Because we're using a container,
a device login will happen, requiring the user to go to a website, enter a code and login.
This only happens once during initialization phase.

#### Configuration

* Environment AZ_SUBSCRIPTION: The Azure subscription to use in this container
* Environment AZ_TENANTID: The Azure tenant id to log into (optional)
* Environment AZ_USE_ARM_SPI: Uses the environment variables ARM_CLIENT_ID and ARM_CLIENT_SECRET for service principal auth [false]

### <a id="gcloud"></a> gcloud

Includes workflows and tools to connect to Google Cloud.

Authentication requires the following:

* Enable [Cloud Resource Manager API](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com)
* Create a [service account](https://console.cloud.google.com/iam-admin/serviceaccounts), that has access to the
  required project
* Create a key and download it as a JSON file
* Mount a directory that contains the JSON file into the CloudControl container and set GCLOUD_KEYPATH accordingly

#### Configuration

* Environment GCLOUD_PROJECTID: The id of the Google Cloud project to connect to
* Environment GCLOUD_USE_SA (Possible values: true, false. Defaults to false): Use a service account to log into Google Cloud. Requires GCLOUD_KEYPATH
* Environment GCLOUD_KEYPATH: Path inside CloudControl that holds the service account JSON file

### <a id="simple"></a> simple

Can be used to connect to infrastructure outside of a specific cloud provider.



### <a id="tanzu"></a> tanzu

Includes workflows and tools to connect to a Tanzu cluster.

#### Note about logins when using the _"kubernetes"_ feature

The kubernetes login tokens usually expire after a few hours already. You can run the `k8s-relogin` script
(located in ~/bin, thus available without path) to re-execute the same login commands as the initialization process
does.

## Features
### <a id="_fish"></a> Fish Shell

Installs and configures the [Fish Shell](https://fishshell.com/) with configured [Spacefish theme](https://spacefish.matchai.me/)

#### Configuration

* USE_fish: Enable this feature
* DEBUG_fish: Debug this feature

### <a id="azcopy"></a> AzCopy

Installs [AzCopy](https://github.com/Azure/azure-storage-azcopy)

#### Configuration

* USE_azcopy: Enable this feature
* DEBUG_azcopy: Debug this feature

### <a id="bitwarden"></a> Bitwarden

Installs the [Bitwarden CLI](https://bitwarden.com/help/cli/)

#### Configuration

* USE_bitwarden: Enable this feature
* DEBUG_bitwarden: Debug this feature

### <a id="certificates"></a> Certificates

Adds specified trusted certificate authorities into the container

#### Configuration

* USE_certificates: Enable this feature
* DEBUG_certificates: Debug this feature
* Add a volume mount to the `volumes:` section of docker compose like this:
       (...)
       volumes:
           - "<Path to directory with CA .pem files>:/certificates"
* Volume-target /certificates: Target directory for certificates. If something different than /certificates is used, environment 
  CERTIFICATES_PATH needs to be set to this path
* Environment CERTIFICATES_PATH: The container path to the volume mount that holds trusted certificate authorities as .pem files 
  (optional). Defaults to `/certificates`. If something different than the default is used, the volume-target needs to be adapted to 
  the same directory

### <a id="direnv"></a> Direnv

Installs [Direnv](https://direnv.net/)

#### Configuration

* USE_direnv: Enable this feature
* DEBUG_direnv: Debug this feature

### <a id="git"></a> Git

Installs [Git](https://git-scm.com/download/)

#### Configuration

* USE_git: Enable this feature
* DEBUG_git: Debug this feature
* Environment GIT_VERSION (optional): Valid Git version to install (e.g. 2.39.0)

### <a id="helm"></a> Helm

Installs [Helm](https://helm.sh)

#### Configuration

* USE_helm: Enable this feature
* DEBUG_helm: Debug this feature
* Environment HELM_VERSION (required): Valid Helm version to install (e.g. 1.5.4)

### <a id="jq"></a> JQ

Installs the [JSON parser and processor jq](https://stedolan.github.io/jq/)

#### Configuration

* USE_jq: Enable this feature
* DEBUG_jq: Debug this feature

### <a id="kc"></a> kc Quick Kubernetes Context switch

Installs [kc](https://github.com/dodevops/cloudcontrol/blob/master/feature/kc/kc.sh), a quick context switcher for kubernetes.


#### Configuration

* USE_kc: Enable this feature
* DEBUG_kc: Debug this feature

### <a id="kubectlnodeshell"></a> Kubectlnodeshell

Installs [kubectl node-shell](https://github.com/kvaps/kubectl-node-shell)

#### Configuration

* USE_kubectlnodeshell: Enable this feature
* DEBUG_kubectlnodeshell: Debug this feature

### <a id="kubernetes"></a> Kubernetes

Installs and configures [kubernetes](https://kubernetes.io/docs/reference/kubectl/overview/) with [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) to connect to the flavour's kubernetes clusters

#### Configuration

* USE_kubernetes: Enable this feature
* DEBUG_kubernetes: Debug this feature
* Environment KUBECTL_DEFAULT_CONTEXT: Sets the default kubectl context after initialisation and when using the
  k8s-relogin script
* (azure flavour) Environment AZ_K8S_CLUSTERS: A comma separated list of AKS clusters to manage
  inside *CloudControl* (only for azure flavour).
  Each cluster is a pair of resource group and cluster name, separated by a colon. Optionally, you can specify
  the target subscription.
  For example: myresourcegroup:myk8s,myotherresourcegroup@othersubscription:mysecondk8s will install myk8s from
  the myresourcegroup resource group and mysecondk8s from the resource group myotherresourcegroup in the
  subscription othersubscription.
  Prefix a cluster name with an ! to load the admin-credentials for that cluster instead of the user credentials.
  This generates the script `k8s-relogin` which allows you to recreate the Kubernetes credentials.
* (azure flavour) Environment AZ_K8S_INSTALL_OPTIONS: Additional options for the az aks install-cli programm.
  (Defaults to empty)
* (aws flavour) Environment AWS_K8S_CLUSTERS: A comma separated list of EKS clusters to manage
  inside *CloudControl* (only for aws flavour).
  For each cluster give the cluster name. If you need to assume an ARN role, add that to the clustername
  with an additional | added.
  For example: myekscluster|arn:aws:iam::32487234892:sample/sample
  
  If you additionally need to assume a role before fetching the EKS credentials, add the role, prefixed with
  an @:
  myekscluster|arn:aws:iam::4327849324:sample/sample@arn:aws:iam::specialrole
* (aws flavour) Environment AWS_SKIP_GPG: If set, skips the gpg checks for the yum repo of kubectl,
  as [this](https://github.com/kubernetes/kubernetes/issues/37922)
  [sometimes](https://github.com/kubernetes/kubernetes/issues/60134)
  seems to fail.
* (simple and aws flavour) Environment KUBECTL_VERSION: The version of kubectl to install
* (tanzu flavour)
  * Environment TANZU_HOST: The tanzu host to download the kubectl vsphere plugin from and authenticate against
  * Environment TANZU_USERNAME: The username to authenticate with
  * Environment KUBECTL_VSPHERE_PASSWORD: The password to authenticate with
  * Environment TANZU_CLUSTERS: A comma separated list of namespace:cluster name pairs
  * Environment TANZU_ADD_CONTROL_CLUSTER: Whether to also authenticate against the control cluster [false]
  * Environment TANZU_SKIP_TLS_VERIFY: Skip TLS verification [false]
  * Environment TANZU_VSPHERE_PLUGIN_PATH: The path where to find the kubectl vsphere plugin [/wcp/plugin/linux-amd64/vsphere-plugin.zip]
  
  This generates the script `k8s-relogin` which allows you to recreate the Kubernetes credentials.
* (gcloud flavor)
  * Environment GCLOUD_K8S_CLUSTERS: A comma separated list of zone:cluster-name
  * Environment K8S_USE_GCLOUD_AUTH: Whether to use the new GKE_GCLOUD_AUTH plugin [true]

### <a id="packages"></a> Packages

Installs additional packages into the container

#### Configuration

* USE_packages: Enable this feature
* DEBUG_packages: Debug this feature
* Environment PACKAGES: A whitespace separated list of packages to install. The packages will be installed with the flavour's default package manager.

### <a id="packer"></a> Packer

Installs [Packer](https://packer.io)

#### Configuration

* USE_packer: Enable this feature
* DEBUG_packer: Debug this feature
* Environment PACKER_VERSION (required): Valid Packer version to install (e.g. 1.5.4)

### <a id="run"></a> Run

Runs commands inside the shell when entering the cloud control container

#### Configuration

* USE_run: Enable this feature
* DEBUG_run: Debug this feature
* Environment RUN_COMMANDS: Valid shell commands to run

### <a id="stern"></a> Stern

Installs [stern](https://github.com/stern/stern), a multi pod and container log tailing for Kubernetes


#### Configuration

* USE_stern: Enable this feature
* DEBUG_stern: Debug this feature
* Environment STERN_VERSION (required): Valid Stern version (e.g. 1.21.0)

### <a id="terraform"></a> Terraform

Installs and configures [Terraform](https://terraform.io)

#### Configuration

* USE_terraform: Enable this feature
* DEBUG_terraform: Debug this feature
* Add a volume mount to the `volumes:` section of docker compose like this:
       (...)
       volumes:
           - "<path-to-terraform>:/terraform"
* Volume-target /terraform: Terraform base target directory. If something different than /terraform is used, environment
  TERRAFORM_PATH needs to be set to this path
* Volume-target /credentials.terraform: A Terraform variable file holding sensitive information when working with terraform (e.g. 
  Terraform app secrets, etc.). If something different than /credentials.terraform is used, environment TERRAFORM_CREDENTIALS_PATH 
  needs to be set to this path
* Environment TERRAFORM_VERSION (required): A valid terraform version to install (e.g. 0.12.17)
* Environment TERRAFORM_PATH: Volume target for terraform base directory (optional). Defaults to `/terraform`. If something different 
  than the default is used, the volume-target needs to be adapted to the same directory
* Environment TERRAFORM_CREDENTIALS_PATH: Volume target for terraform credentials (optional). Defaults to `/terraform`. If something 
  different than the default is used, the volume-target needs to be adapted to the same directory

### <a id="terragrunt"></a> Terragrunt

Installs [Terragrunt](https://github.com/gruntwork-io/terragrunt)

#### Configuration

* USE_terragrunt: Enable this feature
* DEBUG_terragrunt: Debug this feature
* Environment TERRAGRUNT_VERSION (required): Valid version of terragrunt to install

### <a id="timezone"></a> Timezone configuration

Configures the container's timezone

#### Configuration

* USE_timezone: Enable this feature
* DEBUG_timezone: Debug this feature
* Environment TZ: The timezone to use

### <a id="velero"></a> Velero

Installs the [Velero](https://velero.io) kubernetes backup CLI

#### Configuration

* USE_velero: Enable this feature
* DEBUG_velero: Debug this feature
* Environment VELERO_VERSION (required): Valid velero version to install (e.g. 1.4.2)

### <a id="vim"></a> Vim

Installs [Vim](https://www.vim.org/)

#### Configuration

* USE_vim: Enable this feature
* DEBUG_vim: Debug this feature

### <a id="yq"></a> YQ

Installs the [YAML parser and processor yq](https://github.com/mikefarah/yq)

#### Configuration

* USE_yq: Enable this feature
* DEBUG_yq: Debug this feature
* Environment YQ_VERSION (required): Valid YQ version to install (e.g. 4.5.0)


## Development

*CloudControl* supports a decoupled development of features and flavours. If you're missing something, just fork this
repository, create a subfolder for your new feature under "features" and add these files:

* `feature.yaml`: A descriptor for your feature with a title, a description and configuration notes
* `install.sh`: A shell script that is run by CloudControlCenter and should install everything you need
  for your new feature
* `motd.sh`: (optional) If you want to show some information to the users upon login, put them here.

If you need another flavour (aka cloud provider), add a new subdirectory under "flavour" and add a flavour.yaml describing
your flavour the same way as a feature. For the rest of the files, please check out existing flavours for details. Please,
include a sample configuration for your flavour to make it easier for other people to work with it.

### Configuration best practices

The `feature.yaml` is a descriptor file used to automatically create this documentation. It includes a "configuration"
key, that should be used to inform the user of ways to configure the feature. Usually, this is done using
environment variables.

It is recommended to use prefixed variables for the feature. For example, when creating a feature called "myfeature",
use environment variables prefixed with "MYFEATURE_" to circumvent the problem of accidentally sharing configuration
variables with another feature or a flavour.

Additionally, please add enough information to the configuration array of your feature so the user knows what values
to set for the specific environment variable. If a configuration option is required, please state this in the
environment declaration using `(required)` after its name and check if the variable is set in your installation script
and break accordingly if not.

If your feature needs a version specification, the recommended way is to use the environment variable
`[FEATURE NAME]_VERSION`. This variable is also filled if the *CloudControl* user uses the FEATURES-variable approach
to enable features.

### Installer utilities

In your install script, you can source the utils library

    . /feature-installer-utils.sh

#### execHandle

Installation scripts usually echo out some kind of progress, execute something and have to check for errors. The command
`execHandle` does all this in a one liner:

    execHandle "Progress message" command

This will print out "Progress message...", run the command and if it exits with a non-zero status code, it will print
the output of the command and exit with status code 1.

Using this makes installer script way shorter and easier to maintain.

### Integration testing

To validate if your feature correctly installs on a target flavour, [goss](https://github.com/goss-org/goss) is used.

goss can test various things you specify in a yaml formatted file. The *CloudControl* test runner expects a subdirectory
`goss` in your feature, which can hold these files:

  * goss.yaml: A goss file containing tests specific for your feature. See the
    [goss manual](https://github.com/goss-org/goss/blob/master/docs/manual.md) for the available tests. You can also
    use [template](https://github.com/goss-org/goss/blob/master/docs/manual.md#templates) directives to filter
    specific tests only for specific flavours by using e.g. `\{\{ if eq .Env.FLAVOUR "aws" }}(... aws tests)\{\{ end }}`
  * .env: (optional) A file containing environment variable for the automatic tests. Can be empty. **Please do not put
    any sensitive information in this file!**
  * .env.[flavour]: (optional) An .env file that is specifically used for the given flavour
  * .ignore-integration: (optional) Ignore this test for the final integration test (for example if it tests a
    a different shell than the shell in the integration test)

This subdirectory is mounted as /goss-sup into your container. Additionally, another directory which contains
flavour-specific supplemental data (such as access keys) is mounted as /flavour. You can use these two directories
in environment variables and tests to build the required environment for your test.

**Warning**: When doing an integration test of all features, the test runner copies the contents of all supplemental
paths into one directory. Make sure to provide unique filenames for supplemental files for your feature, so they're not
overwritten by a file from another feature in that stage.

The test runner runs tests from all subdirectories starting with "goss", so you can add multiple directories to test
multiple variations of your feature.

### Features for specific flavours ###

If your feature only supports specific flavours, add a `test` key to your `feature.yaml` and under that a 'flavours'
key and list the available flavours. In this example the flavour "some flavour" will only be tested with the gcloud
flavour:

    title: "some flavour"
    test:
      flavours:
        - gcloud

## Building

Build a flavor container image with the base of the repository as the build context like this:

    build.sh [tag] [flavour]

To build all flavours with the same tag, use

    build.sh [tag]

## Testing

To run the test suite for a specific flavour, you need to create a local directory that holds flavour-specific data
(e.g. keys for authentication) and optionally an .env-file with flavour-specific environment variables.

First, you need to compile the test runner:

    cd tests
    docker run --rm -e GOOS=[os, e.g. darwin, linux, windows] -e GOARCH=[architecture, e.g. arm64, amd64] -v "$PWD":/usr/src/myapp -w /usr/src/myapp golang:1.19-alpine go build -o test-features

After that, download the latest goss binary for the target architecture you will test (linux/amd64 or linux/arm64) from
the [Goss site](https://github.com/goss-org/goss) and put it somewhere local.

Once that is done, run the tests like following:

    cd tests
    ./test-features -f [flavour] -i [image:tag] -t [path to flavour-data] -p [test architecture, e.g. linux/amd64] -g [path to the goss binary]

This will run the tests of all features that supply a test suite one by one and, if all succeed, will test all
features together for integration testing. Check out `test-features --help` for other options.

### Testing for failing configurations

If you'd like to test if a specific configuration fails to install, create a goss subdirectory and only put a file
named `.will-fail` into it.

When the testrunner encounters such file it will check if CloudControl fails to complete initialization.

You can add a regular expression pattern into `.will-fail` to test if the container or command output matches it.

### Test debugging

To check why a test failed, run the test-runner using the -x bash parameter to see the different commands it issues.

Then, take the failing command and instead of `dgoss run` execute `docker run` with the same arguments to analyze the
tests locally.

## Building documentation ##

To rebuild this documentation, first compile the documentation maker:

    docker run --rm -e GOOS=[os, e.g. darwin, linux, windows] -e GOARCH=[architecture, e.g. arm64, amd64] -v "$PWD":/usr/src/myapp -w /usr/src/myapp golang:1.19-alpine go run cmd/doc/mkdoc

Then run it to rebuild README.md based on README.md.gotmpl:

    ./mkdoc

## Workflows

This repository includes different workflows to test and automate PRs and Pushes. The following workflows are used:

```mermaid
flowchart TD
    A[Every Push] --> B[Update documentation]
    D[Every PR] --> E[Check commits]
    D --> F[Run Testsuite]
    G[Push to Main] --> H[Generate Changelog and Release]
    G --> C
    I[Push to Develop] --> C[Build images]
    click B "https://github.com/dodevops/cloudcontrol/blob/develop/.github/workflows/docs.yml" "Docs workflow"
    click C "https://github.com/dodevops/cloudcontrol/blob/develop/.github/workflows/image.yml" "Image workflow"
    click E "https://github.com/dodevops/cloudcontrol/blob/develop/.github/workflows/check_commits.yml" "Check workflow"
    click F "https://github.com/dodevops/cloudcontrol/blob/develop/.github/workflows/test.yml" "Test workflow"
    click H "https://github.com/dodevops/cloudcontrol/blob/develop/.github/workflows/release.yml" "Release workflow"
```mermaid
