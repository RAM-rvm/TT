#!/bin/bash
#Filename:install_apache.sh
#Desc : install apache tarball
#Created By : fedoracle
#Date : 2011/10/13-->2011/10/14-->2012/03/02-->2012/03/08

TAR_HOME=/usr/local/src
APACHE_HOME=/usr/local/apache
TAR_NAME=$1
VERSION=`echo ${TAR_NAME%%.tar*}`

#check usage of this script
if [ $# -ne 1 ];then
   echo -e "\033[31m Usage:./$0 httpd-x.x.xx.tar.gz\033[0m"
   exit 1
fi

#Downloading apache
if [ $UID -ne 0 ];then
   echo -e "\033[31m This script must be execute by root!!!!\033[0m"
   exit 1
else
   echo -e "\033[32m User root \033[0m"
fi

#check if apache was installed,if exists,remove it.
/bin/rpm -qa|grep httpd
if [ $? -eq 0 ];then
  /usr/bin/yum -y remove httpd
   echo -e "\033[32m Aapache already removed \033[0m"
else
   echo -e "\033[32m Aapache does not exists \033[0m"
fi

#install development tools requried by apache
for package in autoconf automake gcc gcc-c++ libtool libtool-ltdl libtool-ltdl-devel openssl openssl-devel 
do 
   /usr/bin/yum -y install $package 
done

cd $TAR_HOME
if [ -s $1 ];then
   echo -e "\033[32m $1 Found \033[0m"
else
   echo -e "\033[32m $1 Not Found!!!\033[0m" 
   echo -e "\033[33m Now Starting download \033[0m"
   /usr/bin/wget -c "http://labs.renren.com/apache-mirror/httpd/$1"
   if [ $? -ne 0 ];then
      echo -e "\033[33m Cannot download files!!!Please use other mirrors or url avaliable!!!"
      echo -e "\033[31m Install Ended Unexpected\033[0m"
      exit 111
   else
      echo -e "\033[33m Download Ended \033[0m"
   fi
fi

echo -e "\033[33m Uncompress httpd \033[0m"
/bin/tar -xvf $1
echo -e "\033[33m Uncompress Ended \033[0m"

/bin/sleep 5

#VERSION=`/bin/ls -l | grep httpd | grep -v "tar.gz" | awk -F ':' '{print $2}' | awk '{print $2}'`
cd $VERSION
echo -e "\033[33m Starting configuration \033[0m"
./configure --prefix=$APACHE_HOME --enable-so --enable-rewrite --enable-mods-shared=most
echo -e "\033[33m Configurate Ended \033[0m"
echo ""
echo ""

/bin/sleep 10

echo -e "\033[33m Starting  complie and install\033[0m"
/usr/bin/make && /usr/bin/make install
echo -e "\033[33m Ended complie and install \033[0m"
echo ""
echo ""

/bin/sleep 10

echo -e "\033[33m Copy apachectl as httpd and add apache as a system service\033[0m"
/bin/cp /usr/local/apache/bin/apachectl /etc/init.d/httpd

echo -e "\033[33m Add comment to httpd \033[0m"
/bin/sed -i '/^#!\/bin/a\#chkconfig: 35 61 61\n#description: Apache' /etc/init.d/httpd
echo ""
echo ""

/sbin/chkconfig --add httpd
/sbin/chkconfig httpd on


echo -e "\033[33m Checking apache working or not"
/sbin/service httpd start
/bin/netstat -tnlp | grep 80

if [ $? -eq 0 ];then
   echo -e "\033[031m Apache server started \033[0m"
   echo -e "\033[033m Apche server installed successful!!! \033[0m"
else 
   echo -e "\033[031m Apache does not working \033[0m"
   exit 222
fi

