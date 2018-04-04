#!/bin/bash
#
# Perform lookup of ip/url using geoiplookup and can output to mapscii or google map api.

usage () { 

echo "SYNOPSIS"; 
echo "giomapip [ -g ] [ -m ] [ target IP/URL ] "; 
echo " ";
echo "-m      uses mapsii to display geo location";
echo "-g      uses google to display geo location";
}

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
exit
fi

#Mapscii.coffee file location 
mapscii_file="/Users/dave/Github/mapscii/src/Mapscii.coffee"

#Mapscii.coffee line number for " center: " lon and lat
lineNo=37

#API for google maps
google_api_key=""

#######################################
# function error_code
# error handing
# 
# 
# Arguments:
#   error_code "code" "Message" ${FUNCNAME[0]}
#
# Returns:
# error code 5 retries function
# error code 10 continues
#error code 20 exit 1
#######################################

function error_code() {

if [ "$1" == "5" ]; then
echo $2

while true; do
    read -p "Do you wish try again? [Y/N] " yn
    case $yn in
        [Yy]* ) $3; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Yes or No.";;
    esac
done

fi

if [ "$1" == "10" ]; then
echo $2

while true; do
    read -p "Would you like to continue anyway? [Y/N] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Yes or No.";;
    esac
done

fi

if [ "$1" == "20" ]; then

echo $2

exit 1

fi

}

#######################################
# function tmp_dir_loc
# makes a temp dir with random name
# 
# Returns:
# sets $tmp_dir
#######################################

function tmp_dir_loc() {

 start_temp_name=`basename $0`
           tmp_dir=`mktemp -q -d /tmp/${start_temp_name}.XXXXXX`
           if [ $? -ne 0 ]; then
                   echo "$0: Can't create temp file, exiting..."
                   exit 1
           fi
}

tmp_dir_loc

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
error_code 5 "Can not Connect to the Internet" ${FUNCNAME[0]}
fi
}

is_online

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



function check_hostname() {

Protocol="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"

full_address="$(echo ${1/$Protocol/})"

only_host_name="$(echo ${full_address//} | cut -d/ -f1)"

}

if [ -z "${only_host_name}" ]; then

check_hostname "${net_add}"
echo "${only_host_name}"

fi

lower_case_letter="$(echo {a..z})"
upper_case_letter="$(echo {a..z})"

if [ `expr "${only_host_name}" : ".*[${lower_case_letter} ${upper_case_letter}].*"` -gt 0 ]; then 

is_ip_add="50"; 

fi
       
       
#######################################
# function check_i.p
# if $only_host_name doesn't contane
# letters then checks if is a Valid IP
# is only ran if ${is_ip_add} is empty
# Arguments:
#   check_i.p i.p 
# 
# Returns:
#   error_code 10 if not Valid
#   
#######################################

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

else
  error_code 10 "($ip) is not a Valid I.P"
fi

}

if [ -z "${is_ip_add}" ]; then

check_i.p "${only_host_name}"
is_ip_add=$?

fi

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



function check_connect() {

error_check_ip="$(geoiplookup "$1" | tail -1 | sed -e "s/IP/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/Address/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/not/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/found/a0fe7213be84bac2c1e65d85fb901464/g" | grep -oh "[[:alpha:]]*a0fe7213be84bac2c1e65d85fb901464[[:alpha:]]*" | wc -c | awk '{print $1}')"

error_check_host="$(geoiplookup "$1" | tail -1 | sed -e "s/resolve/a0fe7213be84bac2c1e65d85fb901464/g" | sed -e "s/hostname/a0fe7213be84bac2c1e65d85fb901464/g" | grep -oh "[[:alpha:]]*a0fe7213be84bac2c1e65d85fb901464[[:alpha:]]*" | wc -c | awk '{print $1}')"

if [ "$error_check_ip" = "168" ]; then
error_code 20 "The IP Address was not found"
fi

if [ "$error_check_host" == "66" ]; then
error_code 20 "Can't resolve hostname"
fi

}

if [ -n "${myflag}" ]; then
check_connect "${only_host_name}"

fi

#######################################
# function set_up_lat_lon
# sets get_lat & get_lon
# the hostname/ip by sed'ing the output
# 
#######################################

function set_up_lat_lon() {

get_lat="$(geoiplookup "${only_host_name}" | tail -1 | awk '{print $(NF-3) " " $(NF-2)}' | awk '{print $1}')"

get_lon="$(geoiplookup "${only_host_name}" | tail -1 | awk '{print $(NF-3) " " $(NF-2)}' | awk '{print $2}')"

}

set_up_lat_lon

#######################################
# function set_up_mapsii
# sets up mapsii for running
# 
# 
#######################################

function set_up_mapsii() {

full_line_mapscii="$(echo '    lat: '$get_lat' lon: '$get_lon' ')"
sed -i '' "${lineNo}s/.*/$full_line_mapscii/" ${mapscii_file}
mapscii 

}

if [ "$myflag" == "mapsii" ]; then
set_up_mapsii
fi

#######################################
# function set_up_google
# sets up google for running
# 
# 
#######################################

function set_up_google() {

google_lon="$(echo $get_lon | rev | cut -c 2- | rev)"

google_map_url_small="https://maps.googleapis.com/maps/api/staticmap?center="$get_lat""$google_lon"&zoom=14&size=400x400&key=$google_api_key"

google_map_url_big="https://maps.googleapis.com/maps/api/staticmap?center="$get_lat""$google_lon"&zoom=10&size=400x400&key=$google_api_key"

download_map="$(wget -O $tmp_dir"/smallmap.jpg" $google_map_url_small)"

download_map="$(wget -O $tmp_dir"/bigmap.jpg" $google_map_url_big)"

#$download_map ; qlmanage -d 0 -p /tmp/map.jpg > /dev/null 2>&1

google_address_url="https://maps.googleapis.com/maps/api/geocode/json?latlng="$get_lat""$google_lon"&key=$google_api_key"
wget -O $tmp_dir"/locinfo.json" $google_address_url

echo "$google_address_url"

#cat  /tmp/map.json | jq -r '.results[0].formatted_address'

}

if [ "$myflag" == "google" ]; then
set_up_google
fi

#######################################
# function make_html
# creates giomapip.html in $tmp_dir
# 
# Needs this files about base of $tmp_dir
# bigmap.jpg
# smallmap.jpg
# locinfo.txt
#######################################

function make_html() {
cat > $tmp_dir"/giomapip.html" <<EOF

<html>
<head>
 <v:path o:extrusionok="f" gradientshapeok="t" o:connecttype="rect"/>
 <o:lock v:ext="edit" aspectratio="t"/>
</v:shapetype><v:shape id="Picture_x0020_1" o:spid="_x0000_i1026" type="#_x0000_t75"
 style='width:400pt;height:400pt;visibility:visible;mso-wrap-style:square'>
 <v:imagedata src="smallmap.jpg" o:title=""/>
</v:shape><![endif]--><![if !vml]><img width=400 height=400
src="smallmap.jpg" v:shapes="Picture_x0020_1"><![endif]><!--[if gte vml 1]><v:shape
 id="Picture_x0020_2" o:spid="_x0000_i1025" type="#_x0000_t75" style='width:400pt;
 height:400pt;visibility:visible;mso-wrap-style:square'>
 <v:imagedata src="bigmap.jpg" o:title=""/>
</v:shape><![endif]--><![if !vml]><img width=400 height=400
src="bigmap.jpg" v:shapes="Picture_x0020_2"><![endif]></span></p>
<div><object data="locinfo_finished.txt" width="800" height="400"></object></div>
</body>
</html>


EOF

}

make_html

#######################################
# function get_info_loop
# sed's all JSON info for print_info_loop
#   
#######################################

function get_info_loop() {
post_code_results="$(cat $tmp_dir"/locinfo.json"  | jq -r '.results[].address_components[]' | grep -B 2 "postal_code" | grep "short_name" | sed -e "s/://g" | sed -e "s/short_name//g" | sed -e "s/,//g" | sed -e "s/\"//g" | sort -u )"
country_results="$(cat $tmp_dir"/locinfo.json"  | grep -B 3 "country" | grep "long_name" | sed -e "s/://g" | sed -e "s/long_name//g" | sed -e "s/,//g" | sed -e "s/\"//g" | sort -u)"
admin1_results="$(cat $tmp_dir"/locinfo.json"  | grep -B 3 "administrative_area_level_1" | grep "long_name" | sed -e "s/://g" | sed -e "s/long_name//g" | sed -e "s/,//g" | sed -e "s/\"//g" | sort -u)"
admin2_results="$(cat $tmp_dir"/locinfo.json"  | grep -B 3 "administrative_area_level_2" | grep "long_name" | sed -e "s/://g" | sed -e "s/long_name//g" | sed -e "s/,//g" | sed -e "s/\"//g" | sort -u)"
full_address_results="$(cat $tmp_dir"/locinfo.json"  | jq -r '.results[0].formatted_address')"
latitude_results="$(cat $tmp_dir"/locinfo.json"  | jq -r '.results[0].geometry' | grep -m1 "lat" | sed -e "s/://g" | sed -e "s/lat//g" | sed -e "s/,//g" | sed -e "s/\"//g" | sort -u)"
longitude_results="$(cat $tmp_dir"/locinfo.json"  | jq -r '.results[0].geometry' | grep -m1 "lng" | sed -e "s/://g" | sed -e "s/lng//g" | sed -e "s/,//g" | sed -e "s/\"//g" | sort -u)"
}

get_info_loop

#######################################
# function print_info_loop
# Removes muti-space lines and returns
# single space and adds "*&*" for column
#
# Arguments:
#  e.g | print_info_loop "${full_address_results[@]}" "Full Address"
# 
#   
#######################################

function print_info_loop() {
IFS=$'\n'       
loop_num=1
for j in $1    
do
fixed_space="$(echo "${j}" | tr -s " ")"
    echo "*&*" $2 "*&*" "(""$loop_num"")" "*&*" ":" "*&*" $fixed_space >> $tmp_dir"/locinfo_loop.txt"
    loop_num=$((loop_num+1))
done

}

#######################################
# function create_json_text
# stores all the lines needed for 
# print_info_loop 
#   
#######################################

function create_json_text() {

print_info_loop "${full_address_results[@]}" "Full Address"
print_info_loop "${latitude_results[@]}" "Latitude"
print_info_loop "${longitude_results[@]}" "Longitude"
print_info_loop "${post_code_results[@]}" "Postal Code"
print_info_loop "${country_results[@]}" "Country"
print_info_loop "${admin1_results[@]}" "Administrative Area_Level_1"
print_info_loop "${admin2_results[@]}" "Administrative Area_Level_2"

}

create_json_text

cat $tmp_dir"/locinfo_loop.txt" | column -s "*&*" -t > $tmp_dir"/locinfo_finished.txt"

