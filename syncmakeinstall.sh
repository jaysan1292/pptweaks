#!/bin/bash

syncios=$(which syncios)
make=$(which make)
dpkg=$(which dpkg)
killall=$(which killall)

build_dir=/var/root/dev/pocketplanestweaks

deb=$(ls $build_dir/*.deb|sort -n -t _ -k2.5 -k2.7|tail -1)
version=$(echo $deb|cut -d '_' -f 2|cut -d '-' -f 1)
build=$(echo $(echo $deb|cut -d '_' -f 2|cut -d '-' -f 2)|gawk '{$0 += 1}; END {print $0}')
prefix="com.jaysan1292.pocketplanestweaks_"
suffix="_iphoneos-arm.deb"

newest_deb="$prefix$version-$build$suffix"

cd $build_dir
clear
echo "-----
syncios && make package && dpkg -i $newest_deb && killall -9 \"Pocket Planes\"
-----
"
start_time=$(($(date +%s%N)/1000000))

$syncios && $make package 2>&1 | grep -vE "warning|In function"
returnval=$(echo ${PIPESTATUS[0]})

if [ $returnval -eq 0 ]
then
	$dpkg -i $prefix$version-$build$suffix
fi

end_time=$(($(date +%s%N)/1000000))

total_time=$(echo "$start_time $end_time" | gawk '{$time=($2-$1)/1000}; END{printf "%s", $time}')

if [ $returnval -eq 0 ]
then
	killall -9 "Pocket Planes" 2>/dev/null
	killall -9 "Preferences" 2>/dev/null
	printf "\n=============================
BUILD SUCCESSFUL (%ss)
=============================\n\n" "$total_time"
else
	printf "\n=============================
BUILD FAILED (%ss)
=============================\n\n" "$total_time"
fi

