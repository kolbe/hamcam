#!/usr/bin/env bash
cd /mnt/cam/cam/floathouse/lake/AMC0461CEA066DC1D0/ || exit
for d in 2022-*
do
	[[ -d $d ]] || continue
	printf -v url 'https://api.sunrise-sunset.org/json?formatted=0&lat=47.64&lng=-122.33&date=%s' "$d"
	echo "$d"
	sunset=$( curl -sS "$url" | jq -r .results.sunset )
	sunset_hour=$( date -d "$sunset" +%H )
	for ((h=0; h<24; h++))
	do
		(( sunset_hour-1 <= h && h <= sunset_hour+1 )) && continue
		printf -v prefix %02i "$h"
		files=("$d"/pic_001/"$prefix"*)
		unset files[0]
		echo "$h ${#files[@]}"
		((${#files[@]})) && rm -v "${files[@]}"
	done
done
