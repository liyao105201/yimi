#!/bin/bash
function check_ok () {
    if [ $? -ne 0 ];then
      echo "$1 enable faild"
      exit 886
    fi
}

local_dir=`pwd`
src_dir=/usr/local/src/

cd $src_dir
tar xvf httpd-2.4.51.tar.gz
tar xvf apr-util-1.6.1.tar.gz
tar xvf apr-1.7.0.tar.gz


mkdir /usr/local/{apr,apr-util,httpd}
cd /usr/local/src/apr-1.7.0
./configure --prefix=/usr/local/apr
make -j 2 && make install


cd /usr/local/src/apr-util-1.6.1
./configure --prefix=/usr/local/apr-util/ --with-apr=/usr/local/apr
make -j 2 && make install


cd /usr/local/src/httpd-2.4.51
./configure --prefix=/usr/local/httpd --with-apr=/usr/local/apr  --with-apr-util=/usr/local/apr-util --enable-so --enable-mods-shared=all --enable-rewrite --enable-ssl --enable-deflate --enable-expires --enable-cgi --enable-charset-lite --enable-mpms-shared=all --with-mpm=prefork CPPFLAGS="-I/usr/local/ssl/include/openssl" LDFLAGS="-L/usr/local/ssl/lib"
make -j 2 && make install

cd /usr/local/httpd/bin/ && ./apachectl -v|grep "2.4.51" > /dev/null 2>&1
check_ok apache


/usr/bin/cp $local_dir/libphp5.so /usr/local/httpd/modules/
mkdir /tmp/http_old_conf && cd /etc/httpd/conf
mv httpd.conf /tmp/http_old_conf/
/usr/bin/cp $local_dir/newhttp.conf /etc/httpd/conf/httpd.conf
/usr/bin/cp $local_dir/
