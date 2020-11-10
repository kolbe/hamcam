#!/usr/bin/env bash

info(){
    printf "[INFO] %s\n" "$*"
}

err(){
    printf "[ERROR] %s\n" "$*" >&2
    exit 1
}

basedir='/Volumes/bucket/cam/floathouse/lake/AMC0461CEA066DC1D0/' #2020-11-09/pic_001'

baseurl='https://api.sunrise-sunset.org/json'
lat=47.641757
lng=-122.3381264
printf -v url "%s?lat=%s&lng=%s&formatted=0" "$baseurl" "$lat" "$lng"

printf -v daydir "%s/%(%F)T/pic_001" "$basedir" -1

info "Changing to $daydir"
cd "$daydir" || err

bounds=()
json=$( curl "$url" ) || err "Error fetching from twilight API"
info "$json"
while read -r dt
do 
    bounds+=( "$(TZ=America/Los_Angeles gdate -d "$dt" +"%H.%M")" ) || err "Couldn't fetch bounds"
done < <(
    jq <<<"$json" -r '.results | (.astronomical_twilight_begin, .astronomical_twilight_end)' 
) || err "Couldn't fetch bounds"

info "Using frames from ${bounds[0]} to ${bounds[1]}"

files=(*.jpg)
arrlen=${#files[@]}
info "There are $arrlen files in $daydir"
for (( i=0; i<arrlen; i++ ))
do
    m=0
    [[ "${files[i]}" > "${bounds[0]}" && "${files[i]}" < "${bounds[1]}" ]] && m=1
    #printf '%d %s %d\n' "$i" "${files[i]}" "$m"
    ((m==1)) || unset "files[$i]"
done
files=("${files[@]}")
info "Matched ${#files[@]} files to use as frames"

printf -v outfile "%s/%(%F)T.mp4" ~/Downloads/ -1
{
    for (( i=0; i<${#files[@]}; i+=1000 ))
    do
        cat "${files[@]:i:1000}"
    done
} | 
    ffmpeg -f image2pipe -framerate 60 -i - -vcodec libx264 -preset ultrafast -crf 23 "$outfile"

# https://video.stackexchange.com/questions/7903/how-to-losslessly-encode-a-jpg-image-sequence-to-a-video-in-ffmpeg
# ffmpeg -f image2 -r 30 -i %09d.jpg -vcodec libx264 -profile:v high444 -refs 16 -crf 0 -preset ultrafast a.mp4
