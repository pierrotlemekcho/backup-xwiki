#!/bin/bash
#!/bin/bash

# script de sauvegarde des fichiers Apache nécessaire à une restauration complète sur UBUNTU SERVER 18.04
# pour le fonctionnement de xwiki apache tomcat avec mod -jk
# copie des fichiers server.xml , hosts interfaces et smb.conf en cas de
# reinstallation complete de UBUNTU SERVER
# 



usage() { echo "
# usage bactar [-j] [-s] [-m]
# -j sauvegarde journaliere --> le repertoire lundi/mardi/mercredi....../dimanche
# -s sauvegarde hebdomadaire --> le repertoire 1 2 ...52
# -m sauvegarde manuelle --> le repertoire=$(date '+%Y-%m-%d-%H-%M-%S')
# -u +argument = username pour le repertoire des backups
"; }


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# choix du de la date de sauvegarde
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

while getopts ":jsm:u" opt
do
	echo " option choisi $opt
	case $opt in

		j) DATE=$(date '+%A');;
		s) DATE=$(date '+%W');;
		m) DATE=$(date '+%Y-%m-%d-%H-%M');;
		u) echo " le user est : $OPTARG"
			user=$OPTARG
		\?) usage; exit;; 

	esac
done


echo " sauvegarde dans dans le repertoire :$DATE"


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# import de chemins vers les repertoires de sauvegares
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

source /home/$user/backup/script/repertoires.cnf
echo " variable de repertoires.cnf pour verifier"
