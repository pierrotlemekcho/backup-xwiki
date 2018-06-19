#!/bin/bash

#restauration des données xwiki nécessaire à une restauration complète sur UBUNTU SERVER 16.04
#restaure mysql (1 base xwiki et une base pour chaque sous-wiki)
#par l'utilisateur DBUSER le mot de pass mysql  est gere par mysql_config_editor
#
#restaure de /etc/xwiki fichiers de config
#restaure de /var/lib/xwiki fichier de donnes
#restaure de /usr/lib/xwiki fichier webapps

source repertoires.cnf

#1 base xwiki et une base pour chaque sous-wiki
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


echo " nom du repertoire de restauration "
read DATE

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# on vérifie que le dossier de sauvegarde exite bien 
if [ -d  ${SAUVEFOLDER}/${DATE} ]
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

# il faut recuperer le nom des  bases de donnés a restaurer :wiki +sous wiki,
# elle ont le meme nom que les repertoires contenu dans BASESFOLDER
#bases.list dans le repertoire de sauvegarde contient le nom des bases de données à sauvegarder
# ${SAUVEFOLDER}/${DATE}/bases.list


{ i=0 
while read base 

do
	bases+=" ${base}"
	echo "base : ${base}"
	echo "bases : ${bases}"
done
} < ${SAUVEFOLDER}/${DATE}/bases.list


#restore mysql
for DATABASE in $bases ; do
echo "restoring Mysql base:${DATABASE}"

mysql --login-path=${DBLOGINPATH} -e "SET FOREIGN_KEY_CHECKS=0;"
mysql --login-path=${DBLOGINPATH} -e "DROP DATABASE ${DATABASE};"
mysql --login-path=${DBLOGINPATH} -e "CREATE DATABASE IF NOT EXISTS ${DATABASE} DEFAULT CHARACTER SET utf8;"
gunzip < ${SAUVEFOLDER}/${DATE}/${DATABASE}.sql.gz | mysql  --login-path=${DBLOGINPATH}  
mysql --login-path=${DBLOGINPATH} -e "SET FOREIGN_KEY_CHECKS=1;"

done

mkdir /tmp/${DATE}
#restaure External Data Storage
echo "Restaure data"
## destruction du repertoire corrompu,creation du nouveau repertoire,décompression de l'archive
mkdir /tmp/${DATE}/data
mv -f ${DATAFOLDER}/ /tmp/${DATE}/data
mkdir ${DATAFOLDER}
cd ${DATAFOLDER}
tar -zxf ${SAUVEFOLDER}/${DATE}/data.tar.gz -C ../

#restaure Biblio
if [ -d  ${BIBLIOFOLDER} ]
then
echo "Restaure Biblio"
## destruction du repertoire corrompu,creation du nouveau repertoire,décompression de l'archive
mkdir /tmp/${DATE}/biblio
mv -f ${BIBLIOFOLDER}/ /tmp/${DATE}/biblio
mkdir ${BIBLIOFOLDER}
cd ${BIBLIOFOLDER}
tar -zxf ${SAUVEFOLDER}/${DATE}/Biblio.tar.gz -C ../
fi


#restaure xwiki config et webapps
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
## destruction du repertoire corrompu,creation du nouveau repertoire,décompression de l'archive

mkdir /tmp/${DATE}/config
mv -f ${CONFFOLDER}/ /tmp/${DATE}/config
mkdir ${CONFFOLDER}
cd ${CONFFOLDER}
tar -zxf ${SAUVEFOLDER}/${DATE}/config.tar.gz -C ../


#restaure xwiki webapps 

echo "restaure webapps "
## destruction du repertoire corrompu,creation du nouveau repertoire,décompression de l'archive

mkdir /tmp/${DATE}/webapps
mv -f ${WEBAPPSFOLDER}/ /tmp/${DATE}/webapps
mkdir ${WEBAPPSFOLDER}
cd ${WEBAPPSFOLDER}
tar -zxf ${SAUVEFOLDER}/${DATE}/webapps.tar.gz -C ../


echo "TERMINE"
