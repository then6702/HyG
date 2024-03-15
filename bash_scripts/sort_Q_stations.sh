#!/bin/bash

#file parts
fileStart=~/Desktop/Q_records/data_USGS_ID
fileEnd=.txt
saveFile=~/Desktop/station_list_Q.txt

> $saveFile

IDfile=usgs_IDs.txt
FILE=$IDfile
counter=0
while read line;do
	Qfile=$fileStart$line$fileEnd
	#echo $Qfile
	fileSize=$(stat -f%z $Qfile)
	if [ $fileSize -eq 60 ]; then rm $Qfile; else echo $line >> $saveFile; fi
	((counter++))
	echo $counter
done < $FILE
	
	
	
	
	
	
	
	
	
#if `validate_url $url >/dev/null`; then wget -O ~/Desktop/Q_records/$saveName $url; else echo "does not exist"; fi
