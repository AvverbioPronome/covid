#!/bin/sh

cd "$(dirname "$0")" || exit 1
LASTDOWNLOAD=".lastdownload"

if [ ! -e "$LASTDOWNLOAD" ] || [ "$(date +%s -d 'now - 12 hours')" -ge "$(date +%s -r $LASTDOWNLOAD)" ]; then
    mkdir -p  ./data/dati-json/
    (
	cd ./data/dati-json/ || exit
	wget -N https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni.json
    )
    rm "$LASTDOWNLOAD" || true
    touch "$LASTDOWNLOAD"
fi
