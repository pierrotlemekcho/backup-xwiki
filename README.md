# backup-xwiki
Script de sauvegarde et restauration pour XWIKI sur UBUNTU server 18.04

["Marche à suivre" :](https://sifklic.sif-revetement.com/xwiki/bin/view/P05%20RESSOURCES/Informatiser/installation%20XWIKI%20sif/)

ne pas oublier  mysql_config_editor

# cron
# Restaurer xwiki.

Pour restaurer xwikin on utilise une machine virtuelle qui est configuree en utilisant terraform et ansible.
Terraform permet de creer la machine virtuelle et ansible permet d'y installer les paquets necessaires ains que d'y deployer les fichiers a restaurer

## Preparer son poste de travail
Normalement on a besoin de faire ces etapes qu'un seule fois

### Digital Ocean
Il faut creer un compte chez [Digital Ocean](https://www.digitalocean.com/)
Ainsi qu'un [API Token](https://www.digitalocean.com/docs/api/create-personal-access-token/) qui va permettre a Terrform de communiquer avec l'API de DO (Digital Ocean) pour creer la machine virtuelle

### Terrfaform
Il faut [installer](https://learn.hashicorp.com/terraform/getting-started/install.html) terraform sur le poste que l'on utilise.

### Ansible
Il faut [installer](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-ubuntu) ansible sur le poste que l'on utilise

## Etapes de restaurations

- Recuperer les fichiers de generes par le scripts de sauvegarde pour unue certaine date.
- On se met dans le dossier de ce repo contenant la config ansible et terraform

```
cd xwikirestaure
```
- Generer une clef ssh pour que ansible puisse se connecter en ssh sans mot de passe a la machine virtuelle chez DO
```
ssh-keygen -f xwiki_ssh_key
```
Terraform se fait en deux commandes `terraform plan` puis ensuite `terraform apply` on passe deux parametres. Le token de DO cree plus tot et le chemin vers les fichiers a restaurer
```
terraform plan -var 'do_token=A_REMPLACER_PAR_TOKEN' -var 'xwiki_backup_path=/tmp/2019-07-15-12-12'
terraform apply -var 'do_token=A REMPLACER PAR TOKEN' -var 'xwiki_backup_path=/tmp/2019-07-15-11-12'
```

A titre d'exemple voila le contenu du dossier `/tmp/2019-07-15-12-12`
```
total 1230632
-rw-r--r--  1 alexbaizeau  staff   115M 15 Jul 11:13 Biblio.tar.gz
-rw-r--r--  1 alexbaizeau  staff    13B 15 Jul 11:12 bases.list
-rw-r--r--  1 alexbaizeau  staff    23M 15 Jul 11:13 config.tar.gz
-rw-r--r--  1 alexbaizeau  staff   210M 15 Jul 11:13 data.tar.gz
-rw-r--r--  1 alexbaizeau  staff   2.8M 15 Jul 11:12 sifold.sql.gz
-rw-r--r--  1 alexbaizeau  staff   236M 15 Jul 11:13 webapps.tar.gz
-rw-r--r--  1 alexbaizeau  staff    14M 15 Jul 11:12 xwiki.sql.gz
```

## Verification du wiki

Lorsque la commande `terraform apply` est terminee ( ce qui peut prendre longtemps en fonction de la vitesse d'envoi des donnees ) on recupere l'adress IP de la machine cree dans les log console 

Example de log: ici on voit que l'IP de la machine cree par terraform est  206.81.22.155
```
digitalocean_droplet.xwiki (local-exec): ok: [206.81.22.155]
```

Puis on visitle le wiki et on s'assure qu'il est a jour: http://206.81.12.155:8080/xwiki

## Arret de la machine virtulelle

Quand on est satisfait on supprime tout ce qui a ete cree par terraform pour ne pas payer pour rien avec terraform destroy
```
terraform destroy -var 'do_token=A REMPLACER PAR TOKEN' -var 'xwiki_backup_path=/tmp/2019-07-15-11-12'
```
