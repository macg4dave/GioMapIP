#!/bin/bash

#Mapscii.coffee line number for " center: " lon and lat
lineNo=37

mapscii_file="/Users/dave/Github/mapscii/src/Mapscii.coffee"

net_add="$1"

if [ -z "$net_add" ]; then
echo "Usage:" 
echo "./GioMapIP.sh [IP/URL]"
exit 0
fi

if [ -z "$get_lat" ]; then
	get_lat="$(geoiplookup $net_add | tail -1 | awk '{print $(NF-3) " " $(NF-2)}' | awk '{print $1}')"
echo $get_lat
fi

if [ -z "$get_lat" ]; then
	echo "Can't find latitude"
	exit 1
fi

if [ -z "$get_lon" ]; then
	get_lon="$(geoiplookup $net_add | tail -1 | awk '{print $(NF-3) " " $(NF-2)}' | awk '{print $2}')"
	echo $get_lon

fi

if [ -z "$get_lon" ]; then
	echo "Can't find longitude"
	exit 1
fi

full_line="$(echo '    lat: '$get_lat' lon: '$get_lon' ')"

sed -i '' "${lineNo}s/.*/$full_line/" $mapscii_file

mapscii 