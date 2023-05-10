# -*- encoding: utf-8 -*-
import json
import ovh
import os
import sys
from time import sleep

server_name = os.environ.get('OVH_PROXMOX_SERVER', 'my-server')
hostname = os.environ.get('OVH_CUSTOM_HOSTNAME', 'my-hostname')
ipv4 = os.environ.get('OVH_VIRTUAL_IP', 'my-ip')

# Instanciate an OVH Client.
# You can generate new credentials with full access to your account on
# the token creation page
client = ovh.Client(
    endpoint=os.environ.get('OVH_ENDPOINT', 'ovh-us'),                        # Endpoint of API OVH Europe (List of available endpoints)
    application_key=os.environ.get('OVH_APPLICATION_KEY', 'xxxxxxxxx'),       # Application Key
    application_secret=os.environ.get('OVH_APPLICATION_SECRET', 'xxxxxxxxx'), # Application Secret
    consumer_key=os.environ.get('OVH_CONSUMER_KEY', 'xxxxxxxxx'),             # Consumer Key
)

# Récupération de la liste des adresses MAC du serveur baremetal d'OVH
try:
  print('Récupération de la liste des adresses MAC du serveur baremetal d\'OVH ...')
  mac_address_list = client.get('/dedicated/server/' + server_name + '/virtualMac')
except:
  print('Problème lors de la récupération de la liste des adresses MAC.')
  sys.exit(1)

# Si absence d'adresse MAC
if mac_address_list == [] :
  print('Pas d\'adresse MAC.')
  # Alors création d'une adresse MAC
  try:
    print('Création d\'une adresse MAC virtuelle ...')
    client.post('/dedicated/server/' + server_name + '/virtualMac', 
      ipAddress=ipv4,
      type='ovh',
      virtualMachineName='pfSense',
    )
    print('Adresse MAC virtuelle créée.')
  except Exception as e:
    print('Problème lors de la création d\'une adresse MAC virtuelle.')
    print("Exception: %s" % str(e))
    sys.exit(1)
  sleep(20)
  # Récupération de l'adresse MAC virtuelle précédemment créée
  try:
    print('Récupération de l\'adresse MAC virtuelle précédemment créée ...')
    mac_address = client.get('/dedicated/server/' + server_name + '/virtualMac')[0]
  except:
    print('Problème lors de la récupération de l\'adresse MAC virtuelle précédemment créée.')
    sys.exit(1)
else:
  mac_address = mac_address_list[0]

print('::add-mask::' + mac_address)

with open(os.environ.get('GITHUB_ENV'), 'a') as fh:
    print(f'VIRTUAL_MAC=' + mac_address, file=fh)
