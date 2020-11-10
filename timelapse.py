#!/usr/local/bin/python3

import requests
import os
from datetime import datetime

basedir='/Volumes/bucket/cam/floathouse/lake/AMC0461CEA066DC1D0/' #2020-11-09/pic_001'
today=datetime.today().strftime('%F')

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

files = os.listdir( basedir + today + '/pic_001' )
frames = sorted( f for f in files if begin <= f <= end and f.endswith('.jpg') )

print( frames )
