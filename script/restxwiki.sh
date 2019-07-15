#!/bin/bash

# Script de restauration complète pour xwiki sur UBUNTU SERVER 18 .04
# pour le fonctionnement de xwiki apache tomcat avec mod -jk
#
# la sauvegarde est réaliser par bacxwiki.sh et bacapache.sh
# la configuration des répertoires est decrite dans repertoire.cnf
#
# Ce script restaure:
# -les bases mysql (1 base xwiki et une base pour chaque sous-wiki)
#       par l'utilisateur DBUSER le mot de pass mysql  est gere par mysql_config_editor
#
# -le repertoire  /etc/xwiki fichiers de config
# -le repertoire  /var/lib/xwiki fichier de donnes
# -le repertoire  /usr/lib/xwiki fichier webapps
# -le repetoire  /usr//local/Biblio répertoire de stockage de fichier volumineux , partage samba

# Ce scripte ne restaure pas certain fichiers systeme sauvegarde par bacapache.sh
# il faut le faire à la main




###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# import des chemins vers les repertoires de sauvegardes
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

source repertoires.cnf

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Choix du repertoire de restauration
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo " nom du repertoire de restauration "
read DATE

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# on vérifie que le dossier de sauvegarde exite bien 
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -d  ${SAUVEFOLDERX}/${DATE} ]
then
	echo "le repertoire existe BIEN , on va ecraser les TOUT LES FICHIER avec la nouvelle sauvegarde !!"
else
	echo " le repertoire n'existe pas "
	echo " usage "
	exit 1
fi

echo " restauration des bases mysql et des data : ${DATAFOLDER} les deux doivent etre fait en meme temps"
echo " on va tout détruire avant de restaurer vous etes sûr de continuer o/n ?"
read reponse
if [ ${reponse} = "o" ]
then
	echo " vous semblez ok"
else
	exit 1
fi

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# il faut recuperer le nom des  bases de donnés a restaurer :wiki +sous wiki,
# elle ont le meme nom que les repertoires contenu dans BASESFOLDER
# bases.list dans le repertoire de sauvegarde contient le nom des bases de données à sauvegarder
# ${SAUVEFOLDERX}/${DATE}/bases.list
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{ i=0 
while read base 

do
	bases+=" ${base}"
	echo "base : ${base}"
	echo "bases : ${bases}"
done
} < ${SAUVEFOLDERX}/${DATE}/bases.list


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# restore mysql
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

for DATABASE in $bases ; do
echo "restoring Mysql base:${DATABASE}"

mysql --login-path=${DBLOGINPATH} -e "SET FOREIGN_KEY_CHECKS=0;"
mysql --login-path=${DBLOGINPATH} -e "DROP DATABASE ${DATABASE};"
mysql --login-path=${DBLOGINPATH} -e "CREATE DATABASE IF NOT EXISTS ${DATABASE} DEFAULT CHARACTER SET utf8;"
gunzip < ${SAUVEFOLDERX}/${DATE}/${DATABASE}.sql.gz | mysql  --login-path=${DBLOGINPATH}  
mysql --login-path=${DBLOGINPATH} -e "SET FOREIGN_KEY_CHECKS=1;"

done

mkdir /tmp/${DATE}

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# restaure External Data Storage
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "Restaure data"

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## destruction du repertoire corrompu,creation du nouveau repertoire,décompression de l'archive
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir /tmp/${DATE}/data
mv -f ${DATAFOLDER}/ /tmp/${DATE}/data
mkdir ${DATAFOLDER}
cd ${DATAFOLDER}
tar -zxf ${SAUVEFOLDERX}/${DATE}/data.tar.gz -C ../

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#restaure Biblio
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -d  ${BIBLIOFOLDER} ]
then
echo "Restaure Biblio"

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## destruction du repertoire corrompu,creation du nouveau repertoire,décompression de l'archive
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir /tmp/${DATE}/biblio
mv -f ${BIBLIOFOLDER}/ /tmp/${DATE}/biblio
mkdir ${BIBLIOFOLDER}
cd ${BIBLIOFOLDER}
tar -zxf ${SAUVEFOLDERX}/${DATE}/Biblio.tar.gz -C ../
fi


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#restaure xwiki config et webapps
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo " on va tout détruire avant de restaurer vous etes sûr de continuer o/n ?"
echo " restauration du dossier de config xwiki : ${CONFFOLDER} "
echo " restauration du dossier de webbapsxwiki : ${WEBAPPSFOLDER} "
read reponse
if [ ${reponse} = "o" ]
then
	echo " vous semblez ok"
else
	exit 1
fi

echo "restaure config"

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## destruction du repertoire corrompu,creation du nouveau repertoire,décompression de l'archive
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir /tmp/${DATE}/config
mv -f ${CONFFOLDER}/ /tmp/${DATE}/config
mkdir ${CONFFOLDER}
cd ${CONFFOLDER}
tar -zxf ${SAUVEFOLDERX}/${DATE}/config.tar.gz -C ../


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#restaure xwiki webapps 
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "restaure webapps "

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## destruction du repertoire corrompu,creation du nouveau repertoire,décompression de l'archive
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir /tmp/${DATE}/webapps
mv -f ${WEBAPPSFOLDER}/ /tmp/${DATE}/webapps
mkdir ${WEBAPPSFOLDER}
cd ${WEBAPPSFOLDER}
tar -zxf ${SAUVEFOLDERX}/${DATE}/webapps.tar.gz -C ../


echo "TERMINE"
