#!/bin/bash

#sauvegarde des données xwiki >10.1 nécessaire à une restauration complète sur UBUNTU SERVER 18.04
# 1)dump des bases de données mysql (1 base xwiki et une base pour chaque sous-wiki) 
# par l'utilisateur DBUSER le mot de pass mysql  est gere par mysql_config_editor
#
# 2)backup de /etc/xwiki fichiers de config
# 3)backup de /var/lib/xwiki fichier de données
# 4)backup de /usr/lib/xwiki repertoire de déployement
# 5)backup de /usr/local/Biblio un repertoir de documents creer pour les premeieres version de xwiki <2.?? 
# que l'on garde,ces documents sont accesibles et mis a jour depuis un partage SAMBA

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
# dossier de sauvegarde s'il nexiste pas on le creer
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -d  ${SAUVEFOLDERX}/${DATE} ]
then
	echo "le repertoire existe déja , on va ecraser les fichier avec la nouvelle sauvegarde"
else
	mkdir ${SAUVEFOLDERX}/${DATE}
	echo " le repertoire n'existe pas on le crée et on sauvegarde dedans"
fi


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# il faut recuperer le nom des  bases de donnés a sauvegarder :wiki +sous wiki,
# elle ont le meme nom que les repertoires contenu dans BASESFOLDER
#bases.list contient le nom des bases de données à sauvegarder
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


ls ${BASESFOLDER} > ${SAUVEFOLDERX}/${DATE}/bases.list

{ i=0 
while read base 

do
	bases+=" ${base}"
	echo "base : ${base}"
	echo "bases : ${bases}"
done
} < ${SAUVEFOLDERX}/${DATE}/bases.list


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#backup mysql
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

for DATABASE in $bases ; do
echo "Backup Mysql base:${DATABASE}"

mysqldump  --login-path=${DBLOGINPATH} -h localhost  --max_allowed_packet=512m --add-drop-database --databases ${DATABASE} | gzip > ${SAUVEFOLDERX}/${DATE}/${DATABASE}.sql.gz 
done

echo " fin debug"

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Backup External Data Storage
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


echo "Backup data"
cd ${DATAFOLDER}
echo " repertorer DATAFOLDER  ${DATAFOLDER}"
tar -zcf ${SAUVEFOLDERX}/${DATE}/data.tar.gz ../xwiki/


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Backup xwiki config
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "Backup config"
cd ${CONFFOLDER}
echo " repertorer CONFFOLDER  ${CONFFOLDER}"
tar  -zcf ${SAUVEFOLDERX}/${DATE}/config.tar.gz ../xwiki/

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Backup xwiki webapps 
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "Backup webapps"
cd ${WEBAPPSFOLDER}
tar -zcf ${SAUVEFOLDERX}/${DATE}/webapps.tar.gz ../xwiki/


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Backup Biblio 
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "Backup Biblio"
if [ -d  ${BIBLIOFOLDER} ]
then
cd ${BIBLIOFOLDER}
tar -zcf ${SAUVEFOLDERX}/${DATE}/Biblio.tar.gz ../Biblio/
fi



echo "sauvegarde du : $(date '+%Y-%m-%d-%H-%M') terminé "
echo "***********************  BRAVO   ********************************"
exit 0
