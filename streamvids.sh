#!/bin/bash

rtmp=""
#rtmp="out_$i.mp4"

for i in *mp4; do
	fn="`basename "$i" | rev | cut -c5- | rev`"
	duration="`mediainfo --Output="General;%Duration/String3%" "$i" | rev | cut -c5- | rev`"
	ffmpeg -re -i "$i" -ac 2 -c:v h264 -g 24 -b:v 2M -preset ultrafast -c:a aac -pix_fmt yuv420p -vb 3200k -f flv -flvflags no_duration_filesize "$rtmp"
	sleep 60
done

