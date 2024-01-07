#!/bin/bash

# makeimages.sh
#	Create the png images to overlay at the start and end of the video
#	Execute this in the folder containing the original videos,
#	the intro and outro images will be stored in a new folder, "intros"

outfolder="intros"
mkdir -p "$outfolder"

for i in [A-Z]*mp4; do
	fn="`basename "$i" | rev | cut -c5- | rev`"
	duration="`mediainfo --Output="General;%Duration/String3%" "$i" | rev | cut -c5- | rev`"
	convert /tank/Pictures/TV720.png -size 1280x720 -font helvetica -fill white -pointsize 60 -gravity center -annotate -118+0 "Now playing:\n$fn\n\nDuration: $duration\n\nkick.com/publicdomainmovies" "$outfolder/intro_$fn.png"
	convert /tank/Pictures/TV720.png -size 1280x720 -font helvetica -fill white -pointsize 60 -gravity center -annotate -118+0 "Thank you for watching\n$fn\n\n\n\nkick.com/publicdomainmovies" "$outfolder/outro_$fn.png"
done

