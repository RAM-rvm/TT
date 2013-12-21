#!/bin/bash
#Filename:install_mysql.sh
#Desc: install mysql tarball
#Created By : xiaozhenggang(fedoracle)
#Date: 2011/09/15
#Update time : 2011/10/13 ==>2011/10/14 ==>2011/12/12==>2012/02/20==>2012/03/02==>2012/03/08


MYSQL_DIR=/usr/local/mysql
MYSQL_SRC=/usr/local/src
DATA_DIR=/data/mysql
TAR_NAME=$1
VERSION=`echo ${TAR_NAME%%.tar*}`

#check usage of this script
if [ $# -ne 1 ];then
   echo -e "\033[31m Usage:./$0 mysql-x.x.xx.tar.gz\033[0m"
   exit 1
fi

#check if user is root or not,if not root exit
if [ $UID -ne 0 ];then
   echo -e "\033[31m This script must be execute by root!!!\033[0m"
   exit 1
else
   echo -e "\033[32m User root \033[0m"
fi


# check if already installed  mysql, if exists ,remove it
/bin/rpm -qa | grep mysql
if [ $? -eq 0 ];then
   /usr/bin/yum remove mysql mysql-server -y
   echo -e "\033[32m Mysql already removed \033[0m"
else
   echo -e "\033[32m Mysql does not exist \033[0m"
fi

#check user mysql exists or not
id mysql > /dev/null 2>&1
if [ $? -eq 0  ];then
   echo -e "\033[31m User mysql exists,now remove it;and add a new acount  \033[0m"
   /usr/sbin/userdel -r mysql
   /usr/sbin/groupadd -g 3306 mysql
   /usr/sbin/useradd -u 3306 -g mysql -M -s /sbin/nologin mysql
   echo -e "\033[32m User mysql created \033[0m"
else
   echo -e "\033[31m User mysql does not exists ,now we will create it \033[0m"
   /usr/sbin/groupadd -g 3306 mysql
   /usr/sbin/useradd -u 3306 -g mysql -M -s /sbin/nologin mysql
   echo -e "\033[32m User mysql created \033[0m"
fi

#install development tools requried by mysql
for package in autoconf automake gcc gcc-c++ bison ncurses ncurses-devel
do
   /usr/bin/yum install $package -y
done

#Download and install cmake for mysql 5.5 or newer distribution
cd $MYSQL_SRC
#/bin/ls -l /usr/local/bin/cmake
#if [ $? -ne 0 ];then

if [ -s cmake-2.8.4.tar.gz ];then
   echo -e "\033[32m cmake-2.8.4.tar.gz [Found] \033[0m"
else
   echo -e "\033[32m cmake-2.8.4.tar.gz not found!!!"
   echo -e "\003[32m NOW,Beginning downloading Cmake...... \033[0m"
   /usr/bin/wget -c http://www.cmake.org//files/v2.8/cmake.2.8.4.tar.gz
   if [ $? -eq 0 ];then
      echo -e "\033[31m Cmake Download Ended \033[0m"
   else
      echo -e "\033[0m Download Ended Unexpected!!! \033[0m"
      exit 111
   fi
fi

echo -e "\033[32m Beginning uncompress and install......\033[0m"
/bin/tar -xvf cmake-2.8.4.tar.gz
cd cmake-2.8.4
./configure && /usr/bin/make &&  /usr/bin/make install
if [ $? -eq 0 ];then
   echo -e "\033[31m Cmake Install Ended \033[0m"
else
   echo -e "\033[31m Cmake Install Ended Unexpected!!! \nThere must be some errors while configure,make or install.\nPlease check it out!!!\033[0m"
   exit 222
fi

#else

#Download and install mysql tarball
cd $MYSQL_SRC
if [ -s $1 ];then
   echo -e "\033[32m $1 Found \033[0m"
else
   echo -e "\033[32m $1 Not Found\033[0m"
   echo -e "\033[32m NOW,Beginning download...... \033[0m"
   /usr/bin/wget -c "http://dev.mysql.com/archives/mysql-5.5/$1"
   if [ $? -eq 0 ];then
      echo -e "\033[31m Download Ended \033[0m"
   else
      echo -e "\033[33m Download Ended Unexpected!!!\nMake sure url or mirrors is availiable!!!\033[0m"
      exit 333
   fi
fi

#fi

echo -e "\033[32m Beginning uncompress and install...... \033[0m"
/bin/tar -xvf $1
echo -e "\033[31m Uncompress ended \033[0m"
echo -e "\033[31m Starting configure ==> make ==> make install \033[0m"

#VERSION=`/bin/ls -l | grep mysql|grep -v "tar.gz" | grep "[0-9]$" | awk -F ':' '{print $2}' | awk '{print $2}'`

cd $VERSION	
/usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=$MYSQL_DIR -DMYSQL_DATADIR=$DATA_DIR/data -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all -DMYSQL_TCP_PORT=3306
if [ $? -eq 0 ];then
   echo -e "\033[33m Configuration ended successful!\n Now begin compile and install!!! \033[0m"
   /bin/sleep 5
   /usr/bin/make && /usr/bin/make install
   if [ $? -eq 0 ];then
      echo -e "\033[33m Complie and install successed!!!  \033[0m"
   /bin/sleep 5
   else
      echo -e "\033[33m There must be some problems accured while compiling or installing,Please check it out!!! \033[0m"
      exit 444
   fi
else
   echo -e "\033[33m Configuration error,exit!!! \033[0m "
   exit 555
fi

# now configure your installation
echo -e "\033[32m Make data dir and change owner,mod \033[0m"
/bin/mkdir -p $DATA_DIR/data
/bin/mkdir -p $DATA_DIR/log
/bin/chown -R mysql:mysql $DATA_DIR
/bin/chmod -R 755 $DATA_DIR
echo -e "\033[32m Ended \033[0m"


# use my-medium.cnf as my.cnf
echo -e "\033[32m Set my.cnf \033[0m"
/bin/cp support-files/my-medium.cnf /etc/my.cnf
echo -e "\033[32m Set ended \033[0m"


#initialized database
echo -e "\033[32m Initialized database \033[0m"
$MYSQL_DIR/scripts/mysql_install_db --user=mysql --basedir=$MYSQL_DIR --datadir=$DATA_DIR/data
echo -e "\033[32m Initialized ended \033[0m"


# use mysql.server as mysqld
echo -e "\033[32m Set mysqld \033[0m"
/bin/cp support-files/mysql.server /etc/init.d/mysqld
/bin/chmod +x /etc/init.d/mysqld
echo -e "\033[32m Set ended \033[0m"

# set mysql as system service and start when system boot
echo -e "\033[32m set mysql as system service \033[0m"
/sbin/chkconfig --add mysqld
/sbin/chkconfig mysqld on
echo -e "\033[32m Set ended \033[0m"


# create soft links
echo -e "\033[32m Starting create soft links \033[0m"
cd /usr/local/bin
/bin/ln -s $MYSQL_DIR/bin/mysql mysql 
/bin/ln -s $MYSQL_DIR/bin/mysqldump mysqldump 
/bin/ln -s $MYSQL_DIR/bin/mysqladmin mysqladmin 
echo -e "\033[32m Create ended \033[0m"

echo -e "\033[31m You have installed  successfull!\n Now,starting your adventure with the most popular DBMS in the world!!!\033[0m "
