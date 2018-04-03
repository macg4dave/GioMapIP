#!/bin/bash
#
# Perform lookup of ip/url using geoiplookup and can output to mapscii or google map api.

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

#Mapscii.coffee file location 
mapscii_file="/Users/dave/Github/mapscii/src/Mapscii.coffee"

#Mapscii.coffee line number for " center: " lon and lat
lineNo=37

#API for google maps
google_api_key="AIzaSyAAA7jgh_Q7ZY67KLeWy_L1qmd4-ybi2Eo"

#######################################
# function error_code
# error handing
# 
# 
# Arguments:
#   error_code "code" "Message" 
#
# Returns:
#######################################

function error_code() {

if [ "$1" == "5" ]; then

echo "fatal error with" $2
fi

}


#######################################
# function is_online
# nslookups googles dns
# 
# 
# Arguments:
#   
#
# Returns:
#######################################


function is_online() {

test_google_net="$(nslookup 8.8.8.8 -timeout=1 | grep 'google' | awk '{print $(NF)}' | wc -l | awk '{print $1}')"
if [ "$test_google_net" == "0" ]; then

fi
}


#######################################
# function check_hostname
# extracts hostname from address
# 
# 
# Arguments:
#   check_hostname url
#8
# Returns:
#   $ Protocol
#.  $ full_address
#.  $only_host_name
#######################################

if [ -z "${only_host_name}" ]; then

check_hostname $netadd
echo $only_host_name
fi

lower_case_letter="$(echo {a..z})"
upper_case_letter="$(echo {a..z})"

if [ `expr "$only_host_name" : ".*[${lower_case_letter} ${upper_case_letter}].*"` -gt 0 ];
    then 
       is_ip_add="50"; 
       fi

function check_hostname() {

Protocol="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"

full_address="$(echo ${1/$Protocol/})"

only_host_name="$(echo ${full_address//} | cut -d/ -f1)"
}
       
#######################################
# function check_i.p
# if $only_host_name doesn't contane
# letters then checks if is a Valid IP
# is only ran if ${is_ip_add} is empty
# Arguments:
#   check_i.p i.p 
# 
# Returns:
#   return 90 if not Valid
#   return 100 if is Valid
#######################################
       
if [ -z "${is_ip_add}" ]; then

check_i.p $only_host_name
is_ip_add=$?

fi

function check_i.p() {

ip=$1

if expr "$ip" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
  IFS=.
  set $ip
  for quad in 1 2 3 4; do
    if eval [ \$$quad -gt 255 ]; then
      echo "fail ($ip)"
      exit 1
    fi
  done
  echo "($ip) is a Valid I.P "
  return 100
else
  echo "($ip) is not a Valid I.P"
  return 90
fi

}


#######################################
# function check_connect
# checks that geoiplookup can find
# the hostname/ip by sed'ing the output
# 
# Arguments:
#   check_connect i.p 
#e.g check_connect 8.8.8.8
# Returns:
#   5 on error
#######################################

if [ -n "${myflag}" ]; then
check_connect $net_add
good_to_go=$?
fi

function check_connect() {

check_address="$(geoiplookup "$1" | tail -1 | sed -e "s/IP/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/Address/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/not/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/found/a0fe7213be84bac2c1e65d85fb901464/g" | grep -oh "[[:alpha:]]*a0fe7213be84bac2c1e65d85fb901464[[:alpha:]]*" | wc -c | awk '{print $1}')"

check_url="$(geoiplookup "$1" | tail -1 | sed -e "s/resolve/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/hostname/a0fe7213be84bac2c1e65d85fb901464/g" | grep -oh "[[:alpha:]]*a0fe7213be84bac2c1e65d85fb901464[[:alpha:]]*" | wc -c | awk '{print $1}')"

if [ "$check_address" = "168" ]; then
error_5 "The IP Address was not found"
fi

if [ "$check_url" == "66" ]; then
error_5 "Can't resolve hostname"
fi

}


if [ "$good_to_go" == "0" ]; then

get_lat="$(geoiplookup $net_add | tail -1 | awk '{print $(NF-3) " " $(NF-2)}' | awk '{print $1}')"
echo $get_lat

get_lon="$(geoiplookup $net_add | tail -1 | awk '{print $(NF-3) " " $(NF-2)}' | awk '{print $2}')"
echo $get_lon

fi

if [ "$myflag" == "mapsii" ]; then

full_line_mapscii="$(echo '    lat: '$get_lat' lon: '$get_lon' ')"
sed -i '' "${lineNo}s/.*/$full_line_mapscii/" $mapscii_file
mapscii 

fi

if [ "$myflag" == "google" ]; then

google_lon="$(echo $get_lon | rev | cut -c 2- | rev)"

google_map_url="https://maps.googleapis.com/maps/api/staticmap?center="$get_lat""$google_lon"&zoom=14&size=400x400&key=$google_api_key"

#download_map="$(wget -O /tmp/map.jpg $google_map_url)"

#$download_map ; qlmanage -d 0 -p /tmp/map.jpg > /dev/null 2>&1

#google_address_url="https://maps.googleapis.com/maps/api/geocode/json?latlng="$get_lat""$google_lon"&key=$google_api_key"
#wget -O /tmp/map.json $google_address_url

#cat  /tmp/map.json | jq -r '.results[0].formatted_address'

fi