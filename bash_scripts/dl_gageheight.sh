#!/bin/bash

#script to scrape gage height from USGS website

function validate_url(){
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

urlStart="https://waterdata.usgs.gov/nwis/dv?cb_00065=on&amp;format=rdb&amp;site_no="  #00065 = gage height; 00060 = discharge
urlMid=490000105460001
urlEnd="&amp;referred_module=sw&amp;period=&amp;begin_date=1800-10-01&amp;end_date=2018-09-30"


saveStart=/Users/thomasenzminger/Desktop/stream_channel_proj/GH_records/data_USGS_ID
saveEnd=.txt

IDfile=/Users/thomasenzminger/Desktop/stream_channel_proj/lists/usgs_IDs.txt
FILE=$IDfile

echo $FILE
counter=1

#start the loop
sed 1d $FILE | while read d
do
echo $d

#make file names
url=$urlStart$d$urlEnd
saveName=$saveStart$d$saveEnd

#get the file
if `validate_url $url >/dev/null`; then wget -O $saveName $url; else echo "does not exist"; fi

#check the size
fileSize=$(stat -f%z $saveName)

#if there's no data (size = 60 bytes), just delete the file
if [ $fileSize -eq 60 ]; then rm $saveName; fi

((counter++))
echo $counter
done < $FILE




