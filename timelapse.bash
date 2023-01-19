#!/usr/bin/env bash

basedir='/mnt/cam/cam/floathouse/lake/AMC0461CEA066DC1D0/' #2020-11-09/pic_001'
sunseturl='https://api.sunrise-sunset.org/json'
lat=47.64
lng=-122.33

info(){
    printf '[INFO] %s\n' "$*"
}

err(){
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}

notify(){
	curl --data-urlencode token@/home/kolbe/pushover-lakecam.token \
	    --data-urlencode user@/home/kolbe/pushover-user.token \
	    --data-urlencode message="$*" \
	    https://api.pushover.net/1/messages.json
}

printf -v url '%s?lat=%s&lng=%s&formatted=0' "$sunseturl" "$lat" "$lng"

printf -v daydir '%s/%(%F)T/pic_001' "$basedir" -1

notify "starting timelapse"

info "Changing to $daydir"
cd "$daydir" || err

bounds=()
json=$( curl "$url" ) || err "Error fetching from twilight API"
jq . <<<"$json"
while read -r dt
do
    bounds+=( "$(TZ=America/Los_Angeles date -d "$dt" +"%H.%M")" ) || err "Couldn't fetch bounds"
done < <(
    jq <<<"$json" -r '.results | (.astronomical_twilight_begin, .astronomical_twilight_end)' 
) || err "Couldn't fetch bounds"

# mapfile -t bounds < <(
#     jq -r '
#         .results | 
#         to_entries | .[] |
#         select(.key|match("astronomical_")) |
#             .value |
#             ( gsub("[+].*"; "Z") | fromdate | strflocaltime("%H.%M"))
#     ' <<<"$json"
# )

(( ${#bounds[@]} == 2 )) || err "Couldn't fetch bounds"
bounds[1]=21.00

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

printf -v outfile '%s/%(%F)T.mp4' /mnt/cam/cam/floathouse/lake -1
printf -v title '%(%Y %d %m)T' -1
time {
    for (( i=0; i<${#files[@]}; i+=1000 ))
    do
        cat "${files[@]:i:1000}"
    done
} |
    ffmpeg -f image2pipe -framerate 60 -i - -vcodec libx264 -preset ultrafast -crf 23 "$outfile"

notify "timelapse finished (${#files[@]} frames)"

if output=$( youtube-upload "$outfile" --title "$title" )
then
    notify "upload finished ($output)"
else
    notify "youtube upload FAILED!"
fi

# https://video.stackexchange.com/questions/7903/how-to-losslessly-encode-a-jpg-image-sequence-to-a-video-in-ffmpeg
# ffmpeg -f image2 -r 30 -i %09d.jpg -vcodec libx264 -profile:v high444 -refs 16 -crf 0 -preset ultrafast a.mp4
