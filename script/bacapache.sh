#!/bin/bash

#sauvegarde des fichiers Apache nécessaire à une restauration complète sur UBUNTU SERVER 16.04
#pour le fonctionnement de xwiki apache tomcat avec mod -jk
#copie des fichiers /etc/apache2/sites-available
#copie des



usage() { echo "
# usage bactar [-j] [-s] [-m]
# -j sauvegarde journaliere --> le repertoire lundi/mardi/mercredi....../dimanche
# -s sauvegarde hebdomadaire --> le repertoire 1 2 ...52
# -m sauvegarde manuelle --> le repertoire=$(date '+%Y-%m-%d-%H-%M-%S')
"; }


#SAUVEGARDE folder
SAUVEFOLDER=/home/pierre/backup/apachesauve

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

# dossier de sauvegarde s'il nexiste pas on le creer
if [ -d  ${SAUVEFOLDER}/${DATE} ]
then
	echo "le repertoire existe déja , on va ecraser les fichier avec la nouvelle sauvegarde"
else
	mkdir ${SAUVEFOLDER}/${DATE}
	echo " le repertoire n'existe pas on le crée"
fi

cd /etc/apache2/sites-available/
cp -p *.* ${SAUVEFOLDER}/${DATE}/.
cd /var/www/html/
cp -p index.html ${SAUVEFOLDER}/${DATE}/.
cd /etc/libapache2-mod-jk/
cp -p workers.properties ${SAUVEFOLDER}/${DATE}/.
cd /etc/tomcat8/
cp -p server.xml ${SAUVEFOLDER}/${DATE}/.
cd /etc/
cp -p hosts ${SAUVEFOLDER}/${DATE}/.
cd /etc/network/
cp -p interfaces ${SAUVEFOLDER}/${DATE}/.
cd /etc/samba/
cp -p smb.conf ${SAUVEFOLDER}/${DATE}/.



echo "TERMINE"