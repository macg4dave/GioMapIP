#!/bin/bash

usage () { echo "How to use"; }

options=':m:g:'
while getopts $options option
do
    case $option in
        m  ) myflag="mapsii" net_add=$OPTARG;;
        g  ) myflag="google" net_add=$OPTARG;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

if [ -z "${myflag}" ]; then
usage
fi

#Mapscii.coffee line number for " center: " lon and lat
lineNo=37

mapscii_file="/Users/dave/Github/mapscii/src/Mapscii.coffee"

google_api_key=""


function check_connect {

check_address="$(geoiplookup "$1" | tail -1 | sed -e "s/IP/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/Address/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/not/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/found/a0fe7213be84bac2c1e65d85fb901464/g" | grep -oh "[[:alpha:]]*a0fe7213be84bac2c1e65d85fb901464[[:alpha:]]*" | wc -c | awk '{print $1}')"

check_url="$(geoiplookup "$1" | tail -1 | sed -e "s/resolve/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/hostname/a0fe7213be84bac2c1e65d85fb901464/g" | grep -oh "[[:alpha:]]*a0fe7213be84bac2c1e65d85fb901464[[:alpha:]]*" | wc -c | awk '{print $1}')"

if [ "$check_address" = "168" ]; then
error_5 "The IP Address was not found"
fi

if [ "$check_url" == "66" ]; then
error_5 "Can't resolve hostname"
fi

                }  
                
                
                
                if [ -n "${myflag}" ]; then
    check_connect $net_add
    good_to_go=$?
fi



echo $ip_address_ok
echo $url_adress_ok

echo $good_to_go

if [ "$good_to_go" == "0" ]; then

	get_lat="$(geoiplookup $net_add | tail -1 | awk '{print $(NF-3) " " $(NF-2)}' | awk '{print $1}')"
    echo $get_lat

	get_lon="$(geoiplookup $net_add | tail -1 | awk '{print $(NF-3) " " $(NF-2)}' | awk '{print $2}')"
	echo $get_lon



if [ "$myflag" == "mapsii" ]; then

full_line_mapscii="$(echo '    lat: '$get_lat' lon: '$get_lon' ')"
sed -i '' "${lineNo}s/.*/$full_line_mapscii/" $mapscii_file
mapscii 

fi

if [ "$myflag" == "google" ]; then

google_lon="$(echo $get_lon | rev | cut -c 2- | rev)"

google_map_url="https://maps.googleapis.com/maps/api/staticmap?center="$get_lat""$google_lon"&zoom=14&size=400x400&key=$google_api_key"

download_map="$(wget -O /tmp/map.jpg $google_map_url)"

$download_map ; qlmanage -d 0 -p /tmp/map.jpg > /dev/null 2>&1

google_address_url="https://maps.googleapis.com/maps/api/geocode/json?latlng="$get_lat""$google_lon"&key=$google_api_key"
wget -O /tmp/map.json $google_address_url

cat  /tmp/map.json | jq -r '.results[0].formatted_address'

fi

fi