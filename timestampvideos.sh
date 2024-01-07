#!/bin/bash

v="*mp4"

for i in ${v}; do
	fn="`basename "$i" | rev | cut -c5- | rev`"
	duration="`mediainfo --Output="General;%Duration/String3%" "$i" | rev | cut -c5- | rev`"
	ffmpeg -i "$i" -c:v libx264 -crf 23 -preset medium -movflags +faststart -vf "scale=800:600, \
	drawtext=text=\'%{pts \:gmtime\:0\:%H\\\:%M\\\:%S}\/$duration\' \
	:x=w-tw:y=h-th: fontsize=(h/30):fontcolor=yellow@0.6: box=1: boxcolor=black@0.4, \
	drawtext=text=\'$fn\' \
	:x=0:y=0: fontsize=(h/30):fontcolor=yellow@0.6: box=1: boxcolor=black@0.4" \
	-c:a copy -threads 8 "/dev/shm/timestamped/$i"
done
