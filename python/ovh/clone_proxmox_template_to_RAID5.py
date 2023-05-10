# -*- encoding: utf-8 -*-
import json
import ovh
import os
import urllib.parse
import sys

server_name = os.environ.get('OVH_PROXMOX_SERVER', 'my-server')
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

# Si présence du template existant
try:
  print('Suppression du template existant "' + template_name + '" ...')
  client.delete('/me/installationTemplate/' + template_name)
  print('Template existant "' + template_name + '" supprimé.')
except:
  print('Template "' + template_name + '" inexistant')

# Récupération du nom du template d'OVH
try:
  print("Recherche d'un template OVH proxmox ...")
  result = client.get('/dedicated/server/' + server_name + '/install/compatibleTemplates')["ovh"]
  print( json.dumps(result, indent=4) )
  ovh_template_name = [tpl for tpl in result if "proxmox" in tpl][0]
  print("Template OVH proxmox trouvé : " + ovh_template_name)
except:
  print("Pas de template OVH proxmox trouvé.")
  sys.exit(1)

# Création du nouveau template
try:
  print('Création du template : "' + template_name + '" à partir du template OVH officiel "' + ovh_template_name + '" ...')
  client.post('/me/installationTemplate', 
    baseTemplateName=ovh_template_name,
    defaultLanguage='en',
    name=template_name,
  )
  print('Template "' + template_name + '" créé.')
except:
  print('Problème lors de la création du template "' + template_name + '".')
  sys.exit(1)

# Obtention du schéma de partition
try:
  print('Obtention du schéma de partition du template : "' + template_name + '" ...')
  partitionScheme = client.get('/me/installationTemplate/' + template_name + '/partitionScheme')
  print('Schéma de partition obtenu : ' + partitionScheme[0])
except:
  print("Problème lors de l'obtention du schéma de partition du template \"" + template_name + '".')
  sys.exit(1)

# Obtention des points de montage
try:
  print('Obtention des points de montage du schéma de partition "' + partitionScheme[0] + '" ...')
  mountpointnames = client.get('/me/installationTemplate/' + template_name + '/partitionScheme/' + partitionScheme[0] + '/partition')
  print('Points de montage obtenus.')
except:
  print("Problème lors de l'obtention des points de montage du schéma de partition \"" + partitionScheme[0] + '" ...')
  sys.exit(1)

# Récupération du nom du point de montage dédié à la data
print('Recherche du point de montage dédié à la data sur le schéma de partition "' + partitionScheme[0] + '" ...')
for mountpointname in mountpointnames:
  try:
    print('Récupération des informations du point de montage "' + mountpointname + '" ...')
    mountpointinfos = client.get('/me/installationTemplate/' + template_name + '/partitionScheme/' + partitionScheme[0] + '/partition/' + urllib.parse.quote(mountpointname,safe=''))
    print('Informations du point de montage "' + mountpointname + '" récupérées.')
    if mountpointinfos["volumeName"] == "data" :
      mountpoint = mountpointinfos
      print('Point de montage dédié à la data trouvé : ' + mountpointname)
      break
    print('"' + mountpointname + '" n\'est pas un point de montage dédié à la data.')
  except:
    print('Problème lors de la récupération des informations du point de montage "' + mountpointname + '" ...')
    sys.exit(1)

# Modification du type de RAID sur le point de montage
try:
  print('Modification du type de RAID en RAID 5 sur le point de montage "' + mountpoint["mountpoint"] + '" ...')
  client.put('/me/installationTemplate/' + template_name + '/partitionScheme/' + partitionScheme[0] + '/partition/' + urllib.parse.quote(mountpoint["mountpoint"],safe=''), 
    filesystem=mountpoint["filesystem"],
    mountpoint=mountpoint["mountpoint"],
    order=mountpoint["order"],
    raid='5',
    type=mountpoint["type"],
    volumeName=mountpoint["volumeName"],
 )
  print('Type de RAID modifié en RAID 5 sur le point de montage "' + mountpoint["mountpoint"] + '".')
except:
  print('Problème lors de la définition du type de RAID en RAID 5 sur le point de montage "' + mountpoint["mountpoint"] + '".')
  sys.exit(1)
