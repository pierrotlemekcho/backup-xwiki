#!/bin/bash

# script de sauvegarde des fichiers de configuration apache nécessaires à une
# restauration complète d'xwiki sur UBUNTU SERVER 18.04
# pour le fonctionnement de xwiki apache+tomcat avec mod -jk
# copie des fichiers server.xml, hosts, interfaces, smb.conf

usage() { echo "
# usage bactar [-j] [-s] [-m]
# -j sauvegarde journaliere --> le repertoire lundi/mardi/mercredi....../dimanche
# -s sauvegarde hebdomadaire --> le repertoire 1 2 ...52
# -m sauvegarde manuelle --> le repertoire=$(date '+%Y-%m-%d-%H-%M-%S')
"; }


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# import des chemins pour les repertoires de sauvegares
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

source ~/backup/script/repertoires.cnf

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# date de sauvegarde
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

while getopts ":jsm" opt
do
	case $opt in
		j  ) DATE=$(date '+%A');;
		s  ) DATE=$(date '+%W');;
		m  ) DATE=$(date '+%Y-%m-%d-%H-%M');;
		\? ) usage; exit;; 

	esac
done


echo " sauvegarde dans dans le repertoire :$DATE"

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# si le dossier de sauvegarde n'existe pas on le cree
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -d  ${SAUVEFOLDERA}/${DATE} ]
then
	echo "le repertoire existe déja , on va ecraser les fichier avec la nouvelle sauvegarde"
else
	mkdir ${SAUVEFOLDERA}/${DATE}
	echo " le repertoire n'existe pas on le crée"
fi

cd /etc/apache2/sites-available/
cp -p *.* ${SAUVEFOLDERA}/${DATE}/.
cd /var/www/html/
cp -p index.html ${SAUVEFOLDERA}/${DATE}/.
cd /etc/libapache2-mod-jk/
cp -p workers.properties ${SAUVEFOLDERA}/${DATE}/.
cd /etc/tomcat8/
cp -p server.xml ${SAUVEFOLDERA}/${DATE}/.
cd /etc/
cp -p hosts ${SAUVEFOLDERA}/${DATE}/.
cd /etc/network/
cp -p interfaces ${SAUVEFOLDERA}/${DATE}/.
cd /etc/samba/
cp -p smb.conf ${SAUVEFOLDERA}/${DATE}/.



echo "TERMINE"
