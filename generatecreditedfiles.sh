#!/bin/bash
outfolder="finallydone"
imagesfolder="intros"
inname="intro_"
outname="outro_"
finalname="final_"
introlength=10
t=""

mkdir -p "$outfolder"

while read i; do
	echo ":: $i"
	fn="`basename "$i" | rev | cut -c5- | rev`"
	d=`mediainfo --Inform="Video;%Duration/String3%" "$i"`
	seconds=`echo "(${d:0:2}*3600)+(${d:3:2}*60)+(${d:6:2})+ 1"|bc`
	let "outroseconds=seconds-introlength"
 
	ffmpeg -n -i "${i}" -loop 1 -i "$imagesfolder/${inname}${fn}.png" -loop 1 -i "$imagesfolder/${outname}${fn}.png" \
	-filter_complex " \
		[1]fade=out:st=0:d=${introlength}:alpha=1,setpts=PTS[ovr1]; \
		[2]fade=in:st=0:d=${introlength}:alpha=1,setpts=PTS+${outroseconds}/TB[ovr2]; \
		[0:v][ovr1]overlay=0:0:enable='between(t,0,${introlength})'[base1]; \
		[base1][ovr2]overlay=0:0:enable='between(t,${outroseconds},${seconds})'[out]" -map "[out]" \
		${t} -map 0:a -c:a copy -threads 8 -t $seconds "${outfolder}/${finalname}${i}"
done

#cd /tank/Videos/PublicDomain; ls -b [A-Z]*mp4 | head -n 5 | tail -n 5 | while read line; do echo $line; ./generatecreditedfiles.sh <<< "$line"; done
#cd /tank/Videos/PublicDomain; ls -b [A-Z]*mp4 | head -n 10 | tail -n 5 | while read line; do echo $line; ./generatecreditedfiles.sh <<< "$line"; done
#cd /tank/Videos/PublicDomain; ls -b [A-Z]*mp4 | head -n 15 | tail -n 5 | while read line; do echo $line; ./generatecreditedfiles.sh <<< "$line"; done
#cd /tank/Videos/PublicDomain; ls -b [A-Z]*mp4 | head -n 20 | tail -n 5 | while read line; do echo $line; ./generatecreditedfiles.sh <<< "$line"; done
#cd /tank/Videos/PublicDomain; ls -b [A-Z]*mp4 | head -n 25 | tail -n 5 | while read line; do echo $line; ./generatecreditedfiles.sh <<< "$line"; done
#cd /tank/Videos/PublicDomain; ls -b [A-Z]*mp4 | head -n 30 | tail -n 5 | while read line; do echo $line; ./generatecreditedfiles.sh <<< "$line"; done
#cd /tank/Videos/PublicDomain; ls -b [A-Z]*mp4 | head -n 35 | tail -n 5 | while read line; do echo $line; ./generatecreditedfiles.sh <<< "$line"; done
#cd /tank/Videos/PublicDomain; ls -b [A-Z]*mp4 | head -n 40 | tail -n 5 | while read line; do echo $line; ./generatecreditedfiles.sh <<< "$line"; done
