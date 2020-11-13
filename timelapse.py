#!/usr/local/bin/python3

import asyncio
import requests
import os
import ffmpeg
from datetime import datetime

basedir = '/Volumes/bucket/cam/floathouse/lake/AMC0461CEA066DC1D0/' #2020-11-09/pic_001'
today = datetime.today().strftime('%F')
basedir = os.path.join(basedir, today, 'pic_001')

url='https://api.sunrise-sunset.org/json'
lat=47.641757
lng=-122.3381264

response = requests.get(
        url, params={
            'lat': lat,
            'lng': lng,
            'formatted': 0,
            },
        )

rj = response.json()
begin = datetime.fromisoformat(rj['results']['nautical_twilight_begin']).astimezone().strftime('%H.%M')
end = datetime.fromisoformat(rj['results']['nautical_twilight_end']).astimezone().strftime('%H.%M')

files = os.listdir( basedir )
frames = sorted( f for f in files if begin <= f <= end and f.endswith('.jpg') )


# ffmpeg -f image2pipe -framerate 60 -i - -vcodec libx264 -preset ultrafast -crf 23 "$outfile"

asyncio.create_subprocess_exec
process = (
    ffmpeg
    .input( '-' )
    .output('')
    .global_args(
        '-f', 'image2pipe',
        '-framerate', '60',
        'vcodec', 'libx264',
        'preset', 'ultrafast',
        'crf', '23',
        'output.mp4'
    )
    .run_async(pipe_stdin=True, overwrite_output=True)
)

for frame in frames[:100]:
    f = open(os.path.join(basedir, frame), 'rb')
    process.stdin.write(f.read())
