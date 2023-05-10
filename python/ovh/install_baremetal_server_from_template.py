# -*- encoding: utf-8 -*-
import json
import ovh
import os
import sys
from time import sleep
from datetime import datetime
import pytz

server_name = os.environ.get('OVH_PROXMOX_SERVER', 'my-server')
hostname = os.environ.get('OVH_CUSTOM_HOSTNAME', 'my-hostname')
ssh_key_name = os.environ.get('OVH_SSH_KEY_NAME', 'my-ssh-key')
template_name = os.environ.get('OVH_TEMPLATE', 'ovh-us')

# Instanciate an OVH Client.
# You can generate new credentials with full access to your account on
# the token creation page
client = ovh.Client(
    endpoint=os.environ.get('OVH_ENDPOINT', 'ovh-us'),                        # Endpoint of API OVH Europe (List of available endpoints)
    application_key=os.environ.get('OVH_APPLICATION_KEY', 'xxxxxxxxx'),       # Application Key
    application_secret=os.environ.get('OVH_APPLICATION_SECRET', 'xxxxxxxxx'), # Application Secret
    consumer_key=os.environ.get('OVH_CONSUMER_KEY', 'xxxxxxxxx'),             # Consumer Key
)

# Installation de Proxmox sur le serveur baremetal d'OVH
try:
  print('Lancement de l\'installation de Proxmox sur le serveur baremetal d\'OVH ...')
  client.post('/dedicated/server/' + server_name + '/install/start', 
    details={
      "customHostname": hostname,
      "sshKeyName": ssh_key_name,
    },
    templateName=template_name,
  )
  print('Installation de Proxmox sur le serveur baremetal d\'OVH lancée.')
except Exception as e:
  print('Problème lors du lancement de l\'installation de Proxmox sur le serveur baremetal d\'OVH')
  print("Exception: %s" % str(e))
  sys.exit(1)

# Suivi de l'installation de Proxmox sur le serveur baremetal d'OVH
print("Suivi toutes les minutes de l'installation de Proxmox sur le serveur baremetal d'OVH.")
while True:
  sleep(60)
  print(datetime.now(pytz.timezone('Europe/Paris')).strftime("%d/%m/%Y %H:%M:%S") + ' : Récupération du statut de l\'installation ...')
  try:
    status = client.get('/dedicated/server/' + server_name + '/install/status')
    print(datetime.now(pytz.timezone('Europe/Paris')).strftime("%d/%m/%Y %H:%M:%S") + ' : Serveur en cours d\'installation ...')
    print(json.dumps(status, indent=4))
  except:
    print(datetime.now(pytz.timezone('Europe/Paris')).strftime("%d/%m/%Y %H:%M:%S") + ' : Serveur installé.')
    break
