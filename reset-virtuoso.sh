#! /bin/bash

logFile=/tmp/stdout

#sudo su benchmark -c '/home/benchmark/virtuoso/bin/virtuoso-stop.sh';
#sudo su benchmark -c 'rm -rf /home/benchmark/virtuoso/real';
#sudo su benchmark -c "cd /home/benchmark/virtuoso; tar xf real.tgz"
#sudo su benchmark -c "/home/benchmark/virtuoso/bin/virtuoso-start.sh" |& tee ${logFile}
sudo su -c '/home/benchmark/virtuoso/bin/virtuoso-stop.sh';
sudo su -c 'rm -rf /home/benchmark/virtuoso/real';
sudo su -c "cd /home/benchmark/virtuoso; tar xf real.tar"
sudo su -c "/home/benchmark/virtuoso/bin/virtuoso-start.sh" |& tee ${logFile}


if test "`grep -i -e error ${logFile}`" = ""; then
	echo "Virtuoso reseted: `date`"
else
	echo "Error! Check ${logFile}"
fi
