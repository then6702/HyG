#!/bin/bash

#script to scrape gage drainage area from USGS website

#function validate_url(){
#  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
#}

urlStart="https://waterdata.usgs.gov/nwis/measurements/?site_no="
#urlMid=06730200
#urlMid=01010000
urlEnd="&amp;agency_cd=USGS"

saveStart=~/Desktop/stream_channel_proj/lists/USGS_llde
saveEnd=.txt
saveName=$saveStart$saveEnd

IDfile=~/Desktop/stream_channel_proj/lists/usgs_IDs.txt
FILE=$IDfile

#echo $FILE
#counter=22464

> $saveName
while read line;do
echo $line
#url=$urlStart$line$urlEnd

#if `validate_url $url >/dev/null`; then wget -O - ~/Desktop/$saveName $url; else echo "does not exist"; fi

#save url to text file
curl $urlStart$line > ~/Desktop/tmp_file
echo $urlStart$urlMid

#extract latitude (coarse)
output=$(cat ~/Desktop/tmp_file | grep Latitude | cut -d'"' -f3)

#extract latitude (fine)
latWhole=$(echo ${output:16:2})$'\xc2\xb0'
latFrac=$(echo ${output:24:7})$'"'

lat=$latWhole$latFrac
#echo $lat

#extract longitude (coarse)
output=$(cat ~/Desktop/tmp_file | grep Latitude | cut -d'"' -f4)
#echo $output

#extract longitude (fine)
#check the first character (if 1, then londegree>100, get 3 characters. if >1, londegree<100, get 2 characters)
#test=$(echo ${output:17:1})
#echo $test

lonWhole=$(echo ${output:17:3})$'\xc2\xb0'
lonFrac=$(echo ${output:26:5})$'"'
lon=$lonWhole$lonFrac
#echo $lon

#extract drainage area
dArea=$(cat ~/Desktop/tmp_file | grep Drainage | cut -d' ' -f3)
if [ "$dArea" == "" ]; then dArea=NaN; fi
#echo $dArea

#extract elevation
if [ "$dArea" == "NaN" ]; then 
	elev=$(cat ~/Desktop/tmp_file | grep datum | cut -d' ' -f4)
else
	elev=$(cat ~/Desktop/tmp_file | grep datum | cut -d' ' -f7)
fi

test=$'&nbsp;square&nbsp;miles</div><div'

if [ "$elev" == "$test" ]; then elev=$(cat ~/Desktop/tmp_file | grep datum | cut -d' ' -f10); fi
#echo $elev

if [ "$elev" == "" ]; then elev=NaN;fi

#write to file
spacer="	"
saveline=$lat$spacer$lon$spacer$dArea$spacer$elev
#echo $saveline
echo $saveline >> $saveName

#awk '/<div align="left">Latitude&nbsp;/{print $NF}' ~/Desktop/tmp_file > ~/Desktop/test
((counter++))
#echo $line
done < $FILE




