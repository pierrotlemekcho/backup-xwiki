#!/bin/bash

# script de sauvegarde des fichiers Apache nécessaire à une restauration complète sur UBUNTU SERVER 18.04
# pour le fonctionnement de xwiki apache tomcat avec mod -jk
# copie des fichiers server.xml , hosts interfaces et smb.conf en cas de
# reinstallation complete de UBUNTU SERVER

usage() { echo "
# usage bactar [-j] [-s] [-m] [-u username]
# -j sauvegarde journaliere --> le repertoire lundi/mardi/mercredi....../dimanche
# -s sauvegarde hebdomadaire --> le repertoire 1 2 ...52
# -m sauvegarde manuelle --> le repertoire=$(date '+%Y-%m-%d-%H-%M-%S')
# -u +argument = username pour le repertoire des backups
"; }


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    date de sauvegarde
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

while getopts ":jsmu:" opt
do
	echo " option choisi $opt"
	case $opt in

		j) DATE=$(date '+%A');;
		s) DATE=$(date '+%W');;
		m) DATE=$(date '+%Y-%m-%d-%H-%M');;
		u) echo " le user est : $OPTARG"
			user=$OPTARG;;
		\?) usage
	       		exit 1 ;; 

	esac
done

echo "======== sauvegarde du : $(date '+%Y-%m-%d-%H-%M') ========="
echo "dans le repertoire :~/backup/apachesauve/$DATE de $user "

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# import de chemins vers les repertoires de sauvegares
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

source /home/$user/backup/script/repertoires.cnf

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# dossier de sauvegarde s'il nexiste pas on le crer
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -d  ${SAUVEFOLDERA}/${DATE} ]
then
	echo "le repertoire : ${SAUVEFOLDERA}/${DATE} existe déja ,"
        echo "on va ecraser les fichier avec la nouvelle sauvegarde"
else
	mkdir ${SAUVEFOLDERA}/${DATE}
	echo " le repertoire :${SAUVEFOLDERA}/${DATE} n'existe pas on le crée"
	echo " et on copie les fichiers dedans "
fi

echo " copie de :/etc/apache2/sites-available/"

cd /etc/apache2/sites-available/
cp -p *.* ${SAUVEFOLDERA}/${DATE}/.

echo " copie de :/var/www/html/"                                        

cd /var/www/html/
cp -p index.html ${SAUVEFOLDERA}/${DATE}/.

echo " copie de :/etc/libapache2-mod-jk/"

cd /etc/libapache2-mod-jk/
cp -p workers.properties ${SAUVEFOLDERA}/${DATE}/.

echo " copie de :/etc/tomcat9/"

cd /etc/tomcat9/
cp -p server.xml ${SAUVEFOLDERA}/${DATE}/.

echo " copie de :/etc/"

#cd /etc/
#cp -p hosts ${SAUVEFOLDERA}/${DATE}/.

#echo " copie de :etc/netplan/00-installer-config.yaml"

#cd /etc/netplan/
#cp -p 00-installer-config.yaml ${SAUVEFOLDERA}/${DATE}/.

echo " copie de :/etc/samba/smb.conf"

cd /etc/samba/
cp -p smb.conf ${SAUVEFOLDERA}/${DATE}/.



echo "sauvegarde du : $(date '+%Y-%m-%d-%H-%M') terminé "
echo "***********************  BRAVO   ********************************"
exit 0
