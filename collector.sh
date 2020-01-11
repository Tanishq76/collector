#!/bin/bash

echo "Collector is collecting ----------------------------------------------------------------------------------"

if  [ ! -d "collector_$1" ]
then 
	mkdir collector_$1
	mkdir `pwd`/collector_$1/scans
	mkdir `pwd`/collector_$1/eyewitness
fi

echo "Running sublit3r -----------------------------------------------------------------------------------------"
sublist3r -d $1 -o `pwd`/collector_$1/final.txt  2>/dev/null
echo $1 >> `pwd`/collector_$1/final.txt
echo "Gathering third level domains ----------------------------------------------------------------------------"

for i in $(cat `pwd`/collector_$1/final.txt  | grep  -Eo "(\w+\.\w+\.\w+)$" | sort -u | tee `pwd`/collector_$1/thirdlevel.txt  );
do 
	sublist3r -d $i -o `pwd`/collector_$1/thirdlevel.txt 2>/dev/null | cat `pwd`/collector_$1/thirdlevel.txt >> `pwd`/collector_$1/final.txt

done

echo "Checking for alive domains -------------------------------------------------------------------------------"

cat `pwd`/collector_$1/final.txt | sort -u | httprobe -s -p https:443 | awk -F: '{ print $2 }'| cut -c 3- >> `pwd`/collector_$1/alive.txt

echo "Running nmap ---------------------------------------------------------------------------------------------"
nmap -T4 -iL -A `pwd`/collector_$1/alive.txt -oA `pwd`/collector_$1/scans/scanned.txt 


echo "Running eyewitness ---------------------------------------------------------------------------------------"

eyewitness -f `pwd`/collector_$1/alive.txt -d `pwd`/collector_$1/$1 2>/dev/null


