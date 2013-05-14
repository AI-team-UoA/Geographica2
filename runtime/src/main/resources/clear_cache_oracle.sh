#!/bin/bash
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#24gb ram
#$DIR/Meat 24 $[1*1024*1024]
export ORACLE_HOSTNAME="localhost.localdomain"
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=AL32UTF8
export NLS_LANG=.AL32UTF8
export ORACLE_UNQNAME=AL32UTF8
unset TNS_ADMIN

sudo /etc/init.d/oracle stop
sync && echo 3 > /proc/sys/vm/drop_caches;
sudo chown oracle:oinstall /var/tmp/.oracle
sudo /etc/init.d/oracle start

sleep 1;
echo "clearing cache... `date`" >> $DIR/clear.log

sleep 1;
