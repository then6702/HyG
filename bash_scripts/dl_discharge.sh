#!/bin/bash

#script to scrape discharge records from USGS website

function validate_url(){
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

urlStart="https://nwis.waterdata.usgs.gov/nwis/uv?cb_00060=on&format=rdb&site_no="
#urlMid=490000105460001
urlMid=11507500
urlEnd="&period=&begin_date=1987-10-01&end_date=2022-03-31"

saveStart=data_USGS_ID
saveEnd=.txt

IDfile=usgs_IDs_start22465.txt
FILE=$IDfile

#echo $FILE
#counter=22464

#while read line;do
echo $line
#url=$urlStart$line$urlEnd
url=$urlStart$urlMid$urlEnd
#saveName=$saveStart$line$saveEnd
saveName=$saveStart$urlMid$saveEnd

#if `validate_url $url >/dev/null`; then wget -O ~/Desktop/Q_records/$saveName $url; else echo "does not exist"; fi
if `validate_url $url >/dev/null`; then wget -O ~/Desktop/$saveName $url; else echo "does not exist"; fi
((counter++))
#echo $counter
#done < $FILE




