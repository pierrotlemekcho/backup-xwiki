#!/bin/bash

#sauvegarde des données xwiki >10.1 nécessaire à une restauration complète sur UBUNTU SERVER 16.04
#1)dump des bases de données mysql (1 base xwiki et une base pour chaque sous-wiki) 
#par l'utilisateur DBUSER le mot de pass mysql  est gere par mysql_config_editor
#
#2)backup de /etc/xwiki fichiers de config
#3)backup de /var/lib/xwiki fichier de données
#4)backup de /usr/lib/xwiki repertoire de déployement
#5)backup de /usr/local/Biblio un repertoir de documents creer pour les premeieres version de xwiki <2.?? 
#que l'on garde,ces documents sont accesibles et mis a jour depuis un partage SAMBA




usage() { echo "
# usage bactar [-j] [-s] [-m]
# -j sauvegarde journaliere --> le repertoire lundi/mardi/mercredi....../dimanche
# -s sauvegarde hebdomadaire --> le repertoire 1 2 ...52
# -m sauvegarde manuelle --> le repertoire=$(date '+%Y-%m-%d-%H-%M-%S')
"; }

DBUSER="xwiki"
DBLOGINPATH="xwikidump"

#XWIKI config folder
CONFFOLDER=/etc/xwiki

#XWIKI data folder
DATAFOLDER=/var/lib/xwiki

# repertoire ou trouver les nom des bases de données mysql
BASESFOLDER=/var/lib/xwiki/data/storage

#XWIKI webapps folder
WEBAPPSFOLDER=/usr/lib/xwiki

#Biblio folder
BIBLIOFOLDER=/usr/local/Biblio
#SAUVEGARDE folder
SAUVEFOLDER=/home/pierre/backup/xwikisauve

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if (($# == 0)); 
then
usage
exit 1
fi



while getopts ":jsm" opt
do
	case $opt in
		j  ) DATE=$(date '+%A');;
		s  ) DATE=$(date '+%W');;
		m  ) DATE=$(date '+%Y-%m-%d-%H-%M');;
		\? ) usage 
		    exit 1 

	esac
done


echo " sauvegarde dans dans le repertoire :$DATE"

# dossier de sauvegarde s'il nexiste pas on le creer
if [ -d  ${SAUVEFOLDER}/${DATE} ]
then
	echo "le repertoire existe déja , on va ecraser les fichier avec la nouvelle sauvegarde"
else
	mkdir ${SAUVEFOLDER}/${DATE}
	echo " le repertoire n'existe pas on le crée"
fi

#if false #debug============================================
#then
#code à sauter
# il faut recuperer le nom des  bases de donnés a sauvegarder :wiki +sous wiki,
# elle ont le meme nom que les repertoires contenu dans BASESFOLDER
#bases.list contient le nom des bases de données à sauvegarder
ls ${BASESFOLDER} > ${SAUVEFOLDER}/${DATE}/bases.list

{ i=0 
while read base 

do
	bases+=" ${base}"
	echo "base : ${base}"
	echo "bases : ${bases}"
done
} < ${SAUVEFOLDER}/${DATE}/bases.list


#backup mysql
for DATABASE in $bases ; do
echo "Backup Mysql base:${DATABASE}"

mysqldump  --login-path=${DBLOGINPATH} -h localhost  --max_allowed_packet=512m --add-drop-database --databases ${DATABASE} | gzip > ${SAUVEFOLDER}/${DATE}/${DATABASE}.sql.gz 
done

echo " fin debug"
#fi
#debug============================================================

#Backup External Data Storage
echo "Backup data"
cd ${DATAFOLDER}
echo " repertorer DATAFOLDER  ${DATAFOLDER}"
tar -zcf ${SAUVEFOLDER}/${DATE}/data.tar.gz ../xwiki/


#Backup xwiki config
echo "Backup config"
cd ${CONFFOLDER}
echo " repertorer CONFFOLDER  ${CONFFOLDER}"
tar  -zcf ${SAUVEFOLDER}/${DATE}/config.tar.gz ../xwiki/

#Backup xwiki webapps 
echo "Backup webapps"
cd ${WEBAPPSFOLDER}
tar -zcf ${SAUVEFOLDER}/${DATE}/webapps.tar.gz ../xwiki/


#Backup Biblio 
echo "Backup Biblio"
if [ -d  ${BIBLIOFOLDER} ]
then
cd ${BIBLIOFOLDER}
tar -zcf ${SAUVEFOLDER}/${DATE}/Biblio.tar.gz ../Biblio/
fi

if false #debug============================================
then
#code à sauter
echo " fin debug"
fi
#debug============================================================







echo "TERMINE"