#!/usr/bin/env bash

info(){
    printf "[INFO] %s\n" "$*"
}

err(){
    printf "[ERROR] %s\n" "$*" >&2
    exit 1
}

baseurl='https://api.sunrise-sunset.org/json?formatted=0'
lat=47.64
lng=-122.33
printf -v url "%s&lat=%s&lng=%s" "$baseurl" "$lat" "$lng"

bounds=()
json=$( curl -sS "$url" ) || err "Error fetching from twilight API"

jq '.results | 
    with_entries( 
        select( .key | match("twilight")) | 
        .value |= (
            gsub("[+].*"; "Z") |
            fromdate |
            strflocaltime("%H:%M")
        )
    )' <<<"$json"

