#!/bin/bash
#FileName:install_lamp.sh
#Desc:invoke some scripts to intall mysql,apache,php
#Created By:xiaozhenggang(fedoracle)
#Date:2012/03/12
#Version:1.0

if [ $UID -ne 0 ];then
    echo -e "\033[31m This script must be execute by user root!"
    exit 1
fi

if [ $# -eq 1 ];then
   PKG_VERSION=$1
   PKG_NAME=`echo ${PKG_VERSION%%-*}`
   case $PKG_NAME in
   "mysql")
      bash install_mysql.sh $PKG_VERSION
   ;;
   "httpd")
      bash install_apache.sh $PKG_VERSION
   ;;
   "php")
      bash install_php.sh $PKG_VERSION
   ;;
   *)
      echo -e "\033[31m Package not matched!\nPlease enter full name of the package \nwhich you'll install such as :mysql-5.5.19.tar.gz \033[0m"
      exit 4
   ;;
   esac

elif [ $# -eq 2 ];then
   for PACKAGE in $1 $2
   do
      PKG_VERSION=$PACKAGE
      PKG_NAME=`echo ${PACKAGE%%-*}`
      case $PKG_NAME in
         "httpd")
            bash install_apache.sh $PKG_VERSION
         ;;
         "php")
            bash install_php.sh $PKG_VERSION
         ;;
         *)
            echo -e "\033[31m Package not matched!\nPlease enter full name for the package \nwhich you'll install such as:httpd-2.2.21.tar.gz \033[0m"
            exit 3
      esac
   done

elif [ $# -eq 3 ];then
   for PACKAGE in $1 $2 $3
   do
      PKG_VERSION=$PACKAGE
      PKG_NAME=`echo ${PACKAGE%%-*}`
   
      case $PKG_NAME in
         "mysql")
            bash install_mysql.sh $PKG_VERSION
         ;;
         "httpd")
            bash install_apache.sh $PKG_VERSION
         ;;
         "php")
            bash install_php.sh $PKG_VERSION
         ;;
         *)
            echo -e "\033[31m Package not matched!\nPlease enter full name for the package \nwhich you'll install such as:php-5.3.7.tar.gz \033[0m"
            exit 2
         ;;
      esac
   done

else
   echo -e "\033[31m Parameters enter error!Please make sure you have entired correctly!!! \033[0m"
   exit 1    
fi


