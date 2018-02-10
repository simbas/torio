#!/usr/bin/env bash

source ${TORIO_HOME}/Inquirer.sh/dist/inquirer.sh

text_input "What torrent are you looking for?" query

mkdir -p /tmp/.torio/

curl -o /tmp/.torio/request.txt -G --data-urlencode "q=${query}"  -s --socks5 127.0.0.1:9050 "https://www.skytorrents.in/search/all/ed/1/"

cat /tmp/.torio/request.txt | pup 'tbody tr td:first-of-type a[href^="/info/"] text{}' > /tmp/.torio/result-names.txt
cat /tmp/.torio/request.txt | pup 'tbody tr td:first-of-type a[href^="magnet"] attr{href}' > /tmp/.torio/result-links.txt

IFS=$'\n' torrents=($(cat /tmp/.torio/result-names.txt))
IFS=$'\n' links=($(cat /tmp/.torio/result-links.txt))


list_input "What would you like to eat today?" torrents torrent

for i in "${!torrents[@]}"; do
   if [[ "${torrents[$i]}" = "${torrent}" ]]; then
       curl -o /dev/null -s -F "url=${links[${i}]}" "https://api.put.io/v2/transfers/add?oauth_token=${PUTIO_TOKEN}"
   fi
done
