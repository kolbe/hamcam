#!/usr/bin/env bash

#exec &> "$HOME"/systemd.log
exec >&2

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

date --date "$(jq -r .results.astronomical_twilight_end <<<"$json")" +%s
