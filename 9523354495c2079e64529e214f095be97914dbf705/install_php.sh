#!/bin/bash
#Filename:install_php.sh
#Desc:Auto install php
#Created By:xiaozhenggang(fedoracle)
#Date:2012/03/02==>2012/03/08

PHP_HOME=/usr/local/php
PHP_SRC=/usr/local/src
TAR_NAME=$1
VERSION=`echo ${TAR_NAME%%.tar*}`


#check usage for this script
if [ $# -ne 1 ];then
   echo "Usage:./$0 php-x.x.xx.tar.gz"
   exit 1
fi

#check user is root or not
if [ $UID -ne 0 ];then
   echo "This script must be executed by root!Please change to user root!"
   exit 2
fi

#check php installed or not,if installed,remove it.
/bin/rpm -qa|grep php
if [ $? -eq 0 ];then
   /usr/bin/yum -y remove php
   echo "Php exists,remove it!"
else
   echo "Php does not exists."
fi

#install development tools
for package in gcc gcc-c++ flex autoconf automake bzip2-devel ncurses-devel zlib-devel libjpeg-devel libpng-devel libtif-devel freetype-devel libXpm-devel gettext-devel pam-devel libtool libtool-ltdl libtool-ltdl-devel openssl openssl-devel fontconfig-devel libxml2 libxml2-devel curl-devel libicu libicu-devel mysql-devel libxslt libxslt-devel
do
   /usr/bin/yum -y install $package
done

cd $PHP_SRC
#install libmcrypt libmcrypt-devel limhash libmhash
if [ -s libmcrypt-2.5.7.tar.gz ];then
   echo "libmcrypt-2.5.7 exists,Now start install"
else
   echo "libmcrypt-2.5.7.tar.gz not exists,Now downloading"
   /usr/bin/wget -c ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/libmcrypt/old/libmcrypt-2.5.7.tar.gz
fi

/bin/tar -xvf libmcrypt-2.5.7.tar.gz
cd libmcrypt-2.5.7
./configure
echo "Starting make and make install"
/bin/sleep 5
/usr/bin/make && /usr/bin/make install
/bin/ln -s /usr/local/lib/libmcrypt.a /usr/lib/libmcrypt.a 
/bin/ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la 
/bin/ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so 
/bin/ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
/bin/ln -s /usr/local/lib/libmcrypt.so.4.3.0 /usr/lib/libmcrypt.so.4.3.0
/bin/ln -s /usr/local/lib/libmcrypt.so.4.4.7 /usr/lib/libmcrypt.so.4.4.7
echo "Install ended"

/sbin/ldconfig

/bin/sleep 5

if [ -s mhash-0.9.9.9.tar.bz2 ];then
   echo "mhash-0.9.9.9.tar.bz2 exists,Now start install"
else
   echo "mhash-0.9.9.9.tar.bz2 not exists,Now downloading"
   /usr/bin/wget -c http://ncu.al.sourceforge.net/project/mhash/0.9.9.9/mhash-0.9.9.9.tar.bz
fi

/bin/tar -xvf mhash-0.9.9.9.tar.bz2
cd mhash-0.9.9.9
./configure
echo "Starting make and make install"
/bin/sleep 5
/usr/bin/make && /usr/bin/make install
echo "Install ended"
/bin/sleep 5
cd ../

/bin/ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
/bin/ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
/bin/ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
/bin/ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
/bin/ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/llib/libmhash.so.2.0.1

/sbin/ldconfig

if [ -s mcrypt-2.6.8.tar.gz ];then
   echo "mcrypt-2.6.8.tar.gz exists,Now install"
else
   echo "mcrypt-2.6.8.tar.gz not exists,Now downloading"
   /usr/bin/wget -c http://ncu.dl.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz
fi

/bin/tar -xvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
./configure
echo "Starting make and make install"
/bin/sleep 5
/usr/bin/make && /usr/bin/make install
echo "Install ended"
/bin/sleep 5

/sbin/ldconfig

#install php
cd $PHP_SRC
if [ -s $1 ];then
   echo "$1 exists,Now start install"
else
   echo "$1 not exists,Now downloading"
   /usr/bin/wget -c http://cn2.php.net/distributions/php-5.3.7.tar.bz2
fi

/bin/tar xvf $1
export LDFLAGS=-L/usr/lib64/mysql
#VERSION=`/bin/ls -l | grep php | grep -v "tar" | grep "[0-9]$" | awk -F ':' '{print $2}' | awk '{print $2}'`
cd $VERSION

echo "Start configuration"
/bin/sleep 5
./configure --prefix=$PHP_HOME --with-apxs2=/usr/local/apache/bin/apxs --enable-cgi --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-config-file-path=/usr/local/php/etc --enable-zip --enable-sqlite-utf8 --enable-sockets --enable-soap --enable-pcntl --enable-mbstring --enable-intl --enable-calendar --enable-bcmath --enable-exif --with-mcrypt --with-mhash --with-gd --with-png-dir --with-jpeg-dir --with-freetype-dir --with-libxml-dir --with-curl --with-curlwrappers --with-zlib --with-openssl --with-kerberos=shared --with-gettext=shared --with-xmlrpc=shared --with-xsl --with-iconv

echo "Configure ended,Now start make and make install"
/bin/sleep 10

/usr/bin/make&&/usr/bin/make install

if [ $? -eq 0 ];then
   echo "$VERSION installed successful!!!"
   /bin/sleep 10
else
   echo "Install $VERSION failed!Please check it out and try again!"
   exit 3
fi

/bin/cp php.ini-production /usr/local/php/etc/php.ini


#merge php and apache
/bin/sed -i '/^    AddType application\/x-gzip/a\    AddType application/x-httpd-php .php\' /usr/local/apache/conf/httpd.conf
/bin/sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.php index.html/' /usr/local/apache/conf/httpd.conf

#configure Zend Gurd Loader for php-5.3.x
cd $PHP_SRC
if [ -s ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ];then
   echo "File exists,now start install"
else 
   /usr/bin/wget -c http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
fi

/bin/mkdir -p /usr/local/php/zend
/bin/tar -xvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz 
/bin/cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/php/zend

/bin/cat<<EOF>>/usr/local/php/etc/php.ini
[Zend.Loader]
zend_extension="/usr/local/php/zend/ZendGuardLoader.so"
zend_loader.enable=1
EOF


