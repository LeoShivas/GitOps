# Prerequisites
If you want to manage the servers in a GitOps way, you have to create several SSH keys :
* one for the `root` user on the [dedicated OVH bare metal server](https://www.ovhcloud.com/fr/bare-metal/)
  * this key will used only once, for creating the Ansible user
* one for the dedicated Ansible user on all machines
* one for the pfSense admin user

## SSH keys creation
You can create a SSH key on a temporay Linux VM machine with the following commands :
```
ssh-keygen
```

Example :
```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:gsl5L6M5FV/O94GETrtrCFiyN31+6sM0LQvx9VK5lhk root@140ed833282e
The key's randomart image is:
+---[RSA 3072]----+
|                 |
|                 |
|           .   . |
|   ..+o . + o E  |
|    ==o+SO = + = |
|    o.=o+ @ = B  |
|     ooo.B * + . |
|    .o o. B . .  |
|    o.   o+=     |
+----[SHA256]-----+
```

This will create two files named `id_rsa` (private key) and `id_rsa.pub` (public key):
```
root@140ed833282e:~# ls -l /root/.ssh
total 8
-rw------- 1 root root 2602 Feb 16 22:24 id_rsa
-rw-r--r-- 1 root root  571 Feb 16 22:24 id_rsa.pub
root@140ed833282e:~#
```

You have to do this action as much as you need SSH key. So, feel free to change the name when you can (example : `/root/.ssh/root_rsa` and `/root/.ssh/ansible_rsa`).

## Secrets creation
By following the [official GitHub documentation](https://docs.github.com/fr/actions/security-guides/encrypted-secrets), create the following secrets :
* ADM_NAME
  * The name you want to give to the Ansible account
* ADM_PWD
  * The Ansible account password
* ADM_SSH_PRIVATE_KEY
  * The content of the Ansible SSH private key file (ie: `/root/.ssh/ansible_rsa`)
* ADM_SSH_PUBLIC_KEY
  * The content of the Ansible SSH public key file (ie: `/root/.ssh/ansible_rsa.pub`)
* GH_TKN_SCECRETS_WRITE
  * A GitHub token generated in [Personal access token page](https://github.com/settings/tokens?type=beta) with the `Read access to metadata` and the `Read and Write access to secrets` repository permissions. Follow the [official GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for more information.
* GH_TOKEN_PKR
  * A GitHub Personal Access Token dedicated to Packer build
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

# Install OVH dedicated server

# Create Ansible user on OVH dedicated server
In order to create the Ansible user on the remote servers, you have to define all the hosts in the `all` section in the `hosts.yml` inventory file.
Then, go the Action tab in GitHub and launch the "Install Ansible user" workflow.
This is how it works :
* The workflow is defined by the [.github/workflows/02-ansible-install-ansible-user-workflow.yml](.github/workflows/02-ansible-install-ansible-user-workflow.yml) file
* It uses the [.github/workflows/action-install-ansible/action.yml](.github/workflows/action-install-ansible/action.yml) file, which contains the Ansible install GitHub composite action
  * This action installs :
    * Python
    * Ansible
    * the SSH key given in input
    * the Ansible configuration needed
  * This file can be reused at any time
* It uses the [ansible/playbook-install-proxmox-user.yml](ansible/playbooks/proxmox/playbook-install-proxmox-user.yml) Ansible playbook in order to create the Proxmox user on the remote servers
* It uses the [ansible/playbook-create-proxmox-user-token.yml](ansible/playbooks/playbook-create-proxmox-user-token.yml) Ansible playbook in order to create a Proxmox token and retrieve it
* Then, it store the previously created token in the `PROXMOX_USR_TOKEN_SECRET` GitHub action secret

# Create Proxmox admin user on OVH dedicated server

# Download pfSense ISO

# Create Terraform Proxmox user

# Create pfSense VM template

# Deploy pfSense VM

# Create Ansible pfSense user

# Create Rocky Linux VM template
