#!/bin/bash

backgroundImage="/tank/Pictures/TV720.png"

vidsizeX="1280"
vidsizeY="720"
fps="30"
font="helvetica"
fontcolor="white"
backgroundcolor="black"
pointsize="60"
videobitrate="3200k"
pixfmt="yuv420p"
videoformat="h264"
audioformat="aac"
g="24"
threads="16"

#The inner video will be insizeX by insizeY (1024 by 688)
#The top left of the inner video will be inposX, inposY
inposX=16
inposY=16
insizeX="`echo "$vidsizeX * 0.8" | bc`" # 1280 * 0.8 = 1024
insizeX="${insizeX%%.*}"
insizeY="`echo "$vidsizeY - ($inposY * 2)" | bc`" # 720 - (16 * 2) = 720 - 32 = 688
vidcenterX="`echo "$inposX + ($insizeX / 2)" | bc`" # 16 + (1024 / 2) = 16 + 512 = 528
vidcenterY="`echo "$inposY + ($insizeY / 2)" | bc`" # 16 + (688 / 2) = 16 + 344 = 360
vidcenteroffsetX="`echo "(($vidsizeX - $insizeX) / 2) - $inposX" | bc`" # ((1280 - 1024) / 2) = ((256) / 2) = 128 - 16 = 112
vidcenteroffsetY="`echo "(($vidsizeY - $insizeY) / 2) - $inposY" | bc`" # ((720 - 688) / 2) = ((32) / 2) = 16 - 16 = 0

duration="00:00:00"
seconds=0
#intros: path to intro_*.png and outro_*.png
intros="intros"
finals="finals"
introfilename=intro_
outrofilename=outro_
timestamps="timestamped"

main () {
ov="temp/linkxxlink.mp4"
rm -f "${ov}"
echo ln "${filename}" "${ov}"
ln "${filename}" "${ov}"

convert "${backgroundimage}" -size ${vidsizeX}x${vidsizeY} -font ${font} -fill ${fontcolor} -pointsize ${pointsize} -gravity center -annotate -${vidcenteroffsetX}+${vidcenteroffsetY} "Now playing:\n${fn}\n\nDuration: ${duration}\n\nkick.com/publicdomainmovies" "${intros}/${introfilename}${fn}.png" &
convert "${backgroundimage}" -size ${vidsizeX}x${vidsizeY} -font ${font} -fill ${fontcolor} -pointsize ${pointsize} -gravity center -annotate -${vidcenteroffsetX}+${vidcenteroffsetY} "Thank you for watching\n$fn\n\n\n\nkick.com/publicdomainmovies" "${intros}/${outrofilename}${fn}.png" &
wait

#generate 10 second videos to show at the start and end of the video
ffmpeg -n -f lavfi -i anullsrc -loop 1 -i "${intros}/intro_${fn}.png" \
-ac 2 -ab 96k -c:v h264 -g 24 -b:v 3200k -preset ultrafast -c:a aac -ab 96k \
-pix_fmt yuv420p -vb ${videobitrate} -t ${showintroseconds} -r ${fps} "${intros}/intro_${filename}" &

ffmpeg -n -f lavfi -i anullsrc -loop 1 -i "${intros}/outro_${fn}.png" \
-ac 2 -ab 96k -c:v h264 -g 24 -b:v 3200k -preset ultrafast -c:a aac -ab 96k \
-pix_fmt yuv420p -vb ${videobitrate} -t ${showintroseconds} -r ${fps} "${intros}/outro_${filename}" &

ffmpeg -y -i "${backgroundImage}" -i "${ov}" -map 1:a:0 -filter_complex "[1:v]scale=1024:688[video]; \
[0:v][video]overlay=16:16[bg]; \
[bg]drawtext=text='${cutname}':fontcolor=yellow@0.6: box=1: boxcolor=black@0.4:fontsize=24:x=16:y=16[bg_with_text1]; \
[bg_with_text1]drawtext=text=\'%{pts \:gmtime\:0\:%H\\\:%M\\\:%S}\/${duration}\': \
x=1040-tw:y=h-16-th: fontsize=(h/30):fontcolor=yellow@0.6: box=1: boxcolor=black@0.4[out]" \
-map "[out]" -c:a aac -r ${fps} -threads ${threads} -force_key_frames "expr:gte(t,n_forced*3)" -c:v libx264 -crf 23 -preset medium -movflags +faststart "${finals}/${filename}" 

wait
}

mkdir -p "${intros}" "${finals}" "${timestamps}" "temp"

for line in *.mp4; do
	filename="`basename "${line}"`"
	backfile="`echo ${line} | rev`"
	fn="`echo ${backfile#*.} | rev`"
	if [ "${fn:0:6}" == "final_" ]; then
		cutname="${fn:6}"
	else
		cutname="${fn}"
	fi
	duration="`mediainfo --Inform="Video;%Duration/String3%" "${line}"`"
	duration="${duration:0:8}"
	seconds="`echo "(${duration:0:2}*3600)+(${duration:3:2}*60)+(${duration:6:2})+ 1" |bc`"
	if [ ! -e "${finals}/${filename}" ]; then
		echo "Processing ${filename}"
		main
	else
		echo "${filename} exists, skipping"
	fi
done
