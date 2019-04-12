#!/bin/bash

exts=("odp" "pptx")
log="presentation.log"
old=""
hide="false"

function log () {
	if [ ! -e $log ]; then
		touch $log
	fi
	time=`date +"%Y-%m-%d %H:%M:%S"`
	echo [$time]$1
	echo [$time]$1 >> $log
}

function archive () {
	log "[Archive] Begin archiving"
	for f in *.odp
	do
		if [[ $f != ${1} ]]; then
			date=`date +%Y-%m-%d`
			arch="./archive/$date/"
			mkdir -p ${arch}
			mv "$f" ${arch}"$f"
			log "[Archive] ${arch}${f}"
		fi
	done
}

log 
log "[Start] Start"

while getopts "h" flag; do
	case "${flag}" in
		h) hide="true"; log "[Flag] Hide flag set";;
		*) exit 1 ;;
	esac
done

inotifywait -m -e moved_to --format %f . | while read FILE
do
	if [[ " ${exts[*]} " == *${FILE##*.}* ]]; then
		log "[Valid] Valid extension"
		log "[New] New presentation: {$FILE}"
		log "[Kill] Kill old presentation: {$old}"
		old=$FILE
		killall soffice.bin
		log "[Open] Open new presentation: {${FILE}}"
		if [ $hide == "true" ]; then
			libreoffice --norestore "${FILE}" &
		else
			libreoffice --show --norestore "${FILE}" &
		fi
		archive "${FILE}"
	else
		log "[Invalid] Invalid extension: $FILE"
	fi
done
