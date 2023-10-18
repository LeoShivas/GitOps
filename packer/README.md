# Requirements
If a token is used to build with Packer on Proxmox, you should add the correct permissions to the both accounts : to the user and to the token.

Example :
```
pveum acl modify / -roles Administrator -users myuser
pveum acl modify / -roles Administrator -tokens 'myuser!mytoken'
```

The [ansible/playbook-install-proxmox-user.yml](../ansible/playbooks/proxmox/playbook-install-proxmox-user.yml) file gives the needed permissions.
