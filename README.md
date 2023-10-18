# GitOps

This project is the result of my will to automate all I can on my personal private infrastructure.

Until now, I used a physical VMware server with traditional n-tier VMs architecture, managed by myself from several years (a decade ?).

As I've discovered the DevOps culture and all the automation stuff in my profesional career, I wanted to update this old hosting way.

So, I've decided this :
* Keep a unique physical server with a good ratio disk space / price.
  * I've chosen a [dedicated So You Start (from OVH) bare metal server](https://eco.ovhcloud.com/fr/) with 4x2To disks.
* Use an open source hypervisor
  * I've chosen [Proxmox](https://www.proxmox.com/en/), highly recommended by several work colleagues.
  * This hypervisor is one of the basic ones offered by OVH

The objective of this infrastructure is to host solutions for personal and private use, on the one hand, and, above all, to train myself every day on new IT products, on the other hand.

Currently, I am preparing to pass the [CKA certification (Certified Kubernetes Administrator)](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/). So I'm delving deeper into each aspect of the Kubernetes training that I followed several weeks ago.

## Used technologies
The code in this repository is structured around the following technologies :
* Virtualization
  * Proxmox : https://www.proxmox.com/en/
* [CI/CD](https://www.redhat.com/en/topics/devops/what-is-ci-cd)
  * GitHub Actions : https://docs.github.com/en/actions
* Interact with OVH API
  * Python : https://www.python.org/
* Manage and automate systems configurations
  * Ansible : https://www.ansible.com/
  * Kickstart : [https://access.redhat.com/...kickstart](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/performing_an_advanced_rhel_9_installation/index#performing_an_automated_installation_using_kickstart)
  * cloud-init : https://cloudinit.readthedocs.io/en/latest/
* Routing and Firewalling
  * pfSense : https://www.pfsense.org/
* Infrastructure As Code
  * Terraform : https://www.terraform.io/
* Templating
  * Packer : https://www.packer.io/
* Container Orchestration
  * Kubernetes : https://kubernetes.io/
* Kubernetes Management
  * k9s : https://k9scli.io/
* Kubernetes package manager
  * Helm : https://helm.sh/
* Kubernetes CNI
  * Cilium : https://cilium.io/
* Kubernetes CSI
  * Proxmox : https://github.com/sergelogvinov/proxmox-csi-plugin

## Repository organization
This repository is organized following this way :
* [.github](.github) folder
  * This folder constains all the GitHub Actions workflows
  * All the content of this folder relies on the other folders
* [ansible](ansible), [kickstart](kickstart), [packer](packer), [python](python) and [terraform](terraform) folders
  * These folders respectively contain all their files related own technology stuff
  * All scripts in these folder are orchestrated by the GitHub Actions workflows
* Several repository secrets
  * These secrets are injected as environment variables in the GitHub Actions workflows
* Some repository variables
  * These variables are injected as environment variables in the GitHub Actions workflows

## Secrets creation
By following the [official GitHub documentation](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-an-environment), create the following secrets :
* ADM_MAIL
  * The mail address of the Ansible account
* ADM_NAME
  * The name you want to give to the Ansible account
* ADM_PWD
  * The Ansible account password
* ADM_SSH_PRIVATE_KEY
  * The content of the Ansible SSH private key file (ie: the `/root/.ssh/ansible_rsa` content)
* ADM_SSH_PUBLIC_KEY
  * The content of the Ansible SSH public key file (ie: the `/root/.ssh/ansible_rsa.pub` content)
* GH_TKN_SCECRETS_WRITE
  * A GitHub token generated in [Personal access token page](https://github.com/settings/tokens?type=beta) with the `Read access to metadata` and the `Read and Write access to secrets` repository permissions. Follow the [official GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for more information.
* GH_TOKEN_PKR
  * A GitHub Personal Access Token dedicated to Packer build
* K8S_ENDPOINT
  * The FQDN of the Kubernetes endpoint you want to have
  * I set these FQDN in HAproxy in the pfSense in order to have a TCP proxy in front of the Kubernetes control plane nodes
* MAIL_PASSWORD
  * The password used to authenticate to the smtp server
* MAIL_USERNAME
  * The user used to authenticate to the smtp server
* OVH_APPLICATION_KEY
  * OVH application key (obtained by following the [OVH documentation](https://help.ovhcloud.com/csm/fr-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042789#utilisation-avancee-coupler-les-api-ovhcloud-avec-une-application))
* OVH_APPLICATION_SECRET
  * OVH application secret (obtained by following the [OVH documentation](https://help.ovhcloud.com/csm/fr-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042789#utilisation-avancee-coupler-les-api-ovhcloud-avec-une-application))
* OVH_CONSUMER_KEY
  * OVH consumer key (obtained by following the [OVH documentation](https://help.ovhcloud.com/csm/fr-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042789#utilisation-avancee-coupler-les-api-ovhcloud-avec-une-application))
* OVH_CUSTOM_HOSTNAME
  * The simple host name (without domain)
* OVH_GATEWAY_IP (deprecated)
  * The OVH gateway used by the bare metal server. Can be variabilized ([Find the OVH gateway](https://help.ovhcloud.com/csm/fr-dedicated-servers-network-bridging?id=kb_article_view&sysparm_article=KB0043733)).
* OVH_PROXMOX_SERVER
  * The OVH bare metal server name. Useful if existing other servers. Can be variabilized if only one server.
* OVH_SSH_KEY_NAME
  * The name of the SSH key imported in OVH console to use to deploy to the server
* OVH_SSH_PRIVATE_KEY
  * The content of the root SSH private key file (ie: `/root/.ssh/root_rsa`)
* OVH_SSH_PUBLIC_KEY
  * The content of the root SSH public key file (ie: `/root/.ssh/root_rsa.pub`)
* OVH_VIRTUAL_IP
  * The additional IP to use with Proxmox. Can be variabilized.
* PFSENSE_ADM_PWD
  * The password to use with the pfSense default admin account.
* PFSENSE_ADM_SSH_PRIVATE_KEY
  * The private key to inject to the pfSense default admin account.
* PFSENSE_ADM_SSH_PUBLIC_KEY
  * The public key to use to connect to the pfSense default admin account.
* PFSENSE_SSH_PORT
  * The desired SSH port pfSense is listening to.
* PROXMOX_ADM_NAME
  * The username to use to manage Proxmox
* PROXMOX_ADM_TOKEN_ID
  * The token ID to use to manage Proxmox
* PROXMOX_ADM_TOKEN_SECRET
  * The token secret to use to manage Proxmox
* PROXMOX_FQDN
  * The FQDN associated to the OVH_VIRTUAL_IP. OVH_VIRTUAL_IP can be used directly.
* PROXMOX_URL
  * The complete Proxmox URL. Contains the PROXMOX_FQDN.
* TERRAFORM_CLOUD_ORG
  * The Terraform organization to use
* TERRAFORM_CLOUD_TOKEN
  * The Terraform token to use
* TERRAFORM_CLOUD_WORKSPACE
  * The Terraform workspace to use
* TERRAFORM_USR_NAME
  * The Terraform username to use
* TERRAFORM_USR_TOKEN_ID
  * The Terraform token to use
* TERRAFORM_USR_TOKEN_SECRET
  * The Terraform token secret to use

## Variables creation
By following the [official GitHub documentation](https://docs.github.com/en/actions/learn-github-actions/variables#creating-configuration-variables-for-a-repository), create the following variables :
* CI_ROCKY9_ISO_URL
  * The URL of the cloud-init image to use
  * ie: http://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2
* OVH_ENDPOINT
  * The OVH API endpoint to use
  * ie: ovh-eu
* OVH_TEMPLATE
  * The name the cloned OVH template to give to
  * ie: proxmox7_64_raid5
* PFSENSE_ISO_CHECKSUM
  * The checksum of the pfSense template
  * ie: sha256:941a68c7f20c4b635447cceda429a027f816bdb78d54b8252bb87abf1fc22ee3
* PFSENSE_ISO_FILE
  * The base filename of the pfSense ISO file
  * ie: pfSense-CE-2.6.0-RELEASE-amd64.iso
* PFSENSE_ISO_URL
  * The pfSense ISO file URL to download from
  * ie: https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.6.0-RELEASE-amd64.iso.gz
* ROCKY9_ISO_CHECKSUM
  * The checksum of the Rocky 9 ISO file
  * ie: sha256:bae6eeda84ecdc32eb7113522e3cd619f7c8fc3504cb024707294e3c54e58b40
* ROCKY9_ISO_URL
  * The Rocky 9 ISO file URL to download from
  * ie: https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.1-x86_64-minimal.iso
* TEMPLATE_IP_ADDRESS (obsolete)
  * The IP of the Rocky Packer template (replaced by the cloud-init template)
* TEMPLATE_IP_DNS
  * The DNS IP of the Rocky cloud-init template to use
  * ie: 192.168.1.1
* TEMPLATE_IP_GTW
  * The gateway IP of the Rocky cloud-init template to use
  * ie: 192.168.1.1
* TEMPLATE_IP_MASK
  * The mask network of the Rocky cloud-init template to use
  * ie: 255.255.255.0

## Local play
In order to bypass the GitHub runner and buy some time, you can run manually all the scripts (except those from the [.github](.github) folder). Here is what I added to my `~/.bashrc` file :
```
# OVH variables
export OVH_ENDPOINT=xxxxxxxxxxxxxxxx
export OVH_APPLICATION_KEY=xxxxxxxxxxxxxxxx
export OVH_APPLICATION_SECRET=xxxxxxxxxxxxxxxx
export OVH_CONSUMER_KEY=xxxxxxxxxxxxxxxx
export OVH_PROXMOX_SERVER=xxxxxxxxxxxxxxxx
export OVH_TEMPLATE=xxxxxxxxxxxxxxxx
export OVH_CUSTOM_HOSTNAME=xxxxxxxxxxxxxxxx
export OVH_SSH_KEY_NAME=xxxxxxxxxxxxxxxx
export OVH_VIRTUAL_IP=xxxxxxxxxxxxxxxx
export OVH_ROOT_PWD=xxxxxxxxxxxxxxxx
export PROXMOX_FQDN=xxxxxxxxxxxxxxxx

# Proxmox
export PROXMOX_USER=xxxxxxxxxxxxxxxx
export PROXMOX_TOKEN_ID=xxxxxxxxxxxxxxxx
export PROXMOX_TOKEN_SECRET=xxxxxxxxxxxxxxxx

# Ansible
export ADM_USR=xxxxxxxxxxxxxxxx
export ADM_MAIL=xxxxxxxxxxxxxxxx
export ANSIBLE_STDOUT_CALLBACK=debug
export QCOW2_URL="http://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"

# Packer
export PROXMOX_URL=xxxxxxxxxxxxxxxx
export PROXMOX_USERNAME=xxxxxxxxxxxxxxxx
export PROXMOX_TOKEN=xxxxxxxxxxxxxxxx
export PKR_VAR_prx_node=xxxxxxxxxxxxxxxx
export PACKER_GITHUB_API_TOKEN=xxxxxxxxxxxxxxxx
export PKR_VAR_adm_username=xxxxxxxxxxxxxxxx
export PKR_VAR_adm_ssh_public_key="ssh-rsa AAAAB3xxxxxxxxxxxxxxxxc= xxxxxxxxxxxxxxxx@xxxxxxxxxxxxxxxx"
export PKR_VAR_github_token=xxxxxxxxxxxxxxxx
export PKR_VAR_github_repo="LeoShivas/xxxxxxxxxxxxxxxx"
export PKR_VAR_github_ref_name="main"
export PKR_VAR_bind_ip_address=xxxxxxxxxxxxxxxx
export PKR_VAR_bind_ssh_port=xxxxxxxxxxxxxxxx
export PKR_VAR_bind_ssh_user=xxxxxxxxxxxxxxxx
export PKR_VAR_adm_pwd=xxxxxxxxxxxxxxxx
export PKR_VAR_ip_address=xxxxxxxxxxxxxxxx
export PKR_VAR_ip_gtw=xxxxxxxxxxxxxxxx
export PKR_VAR_ip_mask=xxxxxxxxxxxxxxxx
export PKR_VAR_ip_dns=xxxxxxxxxxxxxxxx

# Packer pfSense
export PKR_VAR_iso_file="pfSense-CE-2.6.0-RELEASE-amd64.iso"
export PKR_VAR_virtual_mac=xxxxxxxxxxxxxxxx
export PKR_VAR_ip_address=xxxxxxxxxxxxxxxx
export PKR_VAR_ip_gateway=xxxxxxxxxxxxxxxx
export PKR_VAR_pfsense_adm_pwd=xxxxxxxxxxxxxxxx
export PKR_VAR_pfsense_ssh_port=xxxxxxxxxxxxxxxx
export PKR_VAR_pfsense_adm_ssh_public_key="ssh-rsa AAAABxxxxxxxxxxxxxxxxc="
export PKR_VAR_ansible_usr_pwd=xxxxxxxxxxxxxxxx

# Terraform
export TF_CLOUD_ORGANIZATION=xxxxxxxxxxxxxxxx
export TF_WORKSPACE=xxxxxxxxxxxxxxxx
export TF_TOKEN_app_terraform_io=xxxxxxxxxxxxxxxx
export PM_API_URL=xxxxxxxxxxxxxxxx
export PM_API_TOKEN_ID=xxxxxxxxxxxxxxxx
export PM_API_TOKEN_SECRET=xxxxxxxxxxxxxxxx
export TF_VAR_prx_node=xxxxxxxxxxxxxxxx
export TF_VAR_ip_dns=xxxxxxxxxxxxxxxx
export TF_VAR_mac_address=xxxxxxxxxxxxxxxx
export TF_VAR_adm_pwd=xxxxxxxxxxxxxxxx
export TF_VAR_adm_private_key="-----BEGIN OPENSSH PRIVATE KEY-----
xxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxx
xxxxx==
-----END OPENSSH PRIVATE KEY-----"
export TF_VAR_adm_username=xxxxxxxxxxxxxxxx
export TF_VAR_bind_ip_address=xxxxxxxxxxxxxxxx
export TF_VAR_bind_ssh_port=xxxxxxxxxxxxxxxx
export TF_VAR_bind_ssh_private_key="-----BEGIN OPENSSH PRIVATE KEY-----
xxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxx
xxxxx==
-----END OPENSSH PRIVATE KEY-----"
export TF_VAR_bind_ssh_user=xxxxxxxxxxxxxxxx
export TF_VAR_kube_cp_count=3
export TF_VAR_kube_wk_count=3
export TF_VAR_template_ip_address=xxxxxxxxxxxxxxxx
export TF_VAR_root_private_key="-----BEGIN OPENSSH PRIVATE KEY-----
xxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxx=
-----END OPENSSH PRIVATE KEY-----"

# Packer Rocky
export PKR_VAR_iso_url="https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.1-x86_64-minimal.iso"
export PKR_VAR_iso_checksum="sha256:bae6eeda84ecdc32eb7113522e3cd619f7c8fc3504cb024707294e3c54e58b40"

# Kubernetes
export K8S_ENDPOINT=xxxxxxxxxxxxxxxx
```
You should update all the values.
