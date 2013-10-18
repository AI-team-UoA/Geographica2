#! /bin/bash

if test ! -d ToDelete; then
	mkdir ToDelete
fi
cd ToDelete

if test ! -d `date +%y%m%d-%H%M%S`; then
	mkdir `date +%y%m%d-%H%M%S`
fi
cd `date +%y%m%d-%H%M%S`

for f in `ls -d ../../geographica*out`; do
	sudo mv $f `date +%y%m%d-%H%M%S`
done


cd ~benchmark/Results
sudo rm -f geographica.log

if test ! -d ToDelete; then
	mkdir ToDelete
fi
cd ToDelete

if test ! -d `date +%y%m%d-%H%M%S`; then
	mkdir `date +%y%m%d-%H%M%S`
fi
cd `date +%y%m%d-%H%M%S`

for f in `ls -d ../../*SUT*`; do
	sudo mv $f `date +%y%m%d-%H%M%S`
done
