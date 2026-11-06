#!/bin/bash
# make_shots.sh <sweep dir> <out dir> : squared CRT shots for the 23
# contact-list steps (sharpest of the 6 frames = largest JPEG), plus a
# numbered contact sheet
D=$1; O=$2; S=$(dirname "$(readlink -f "$0")")
mkdir -p "$O/crt" "$O/lab"
names=(VCR=Off VCR=Damaged Roll=FastDown Tear=Severe Tear=Burst Jitter=Heavy Flag=Severe Skew=Severe Wow=Deep Drop=Heavy Drop=Crease HeadSw=Severe Hue=p90 Hue=180 Hue=m45 Hue=Off Burst=25 Burst=Off Burst=Flicker Subcar=p5k CDelay=4.5us CNoise=Severe CBW=Broadcast Drop=Stress Heads=Dirty Heads=VeryDirty Heads=BothClogged VCR=Failing Bars_VCR=Worn Bars_VCR=Damaged Roll=SlowDown Wow=Typical)
i=0
for n in "${names[@]}"; do
	d=$(ls -d "$D"/[0-9][0-9][0-9]_$n 2>/dev/null | grep -v IL0 | head -1)
	[ -z "$d" ] && d=$(ls -d "$D"/*_$n 2>/dev/null | grep -v IL0_ | head -1)
	[ -z "$d" ] && { echo "missing $n"; continue; }
	best=""; bs=0
	for f in "$d"/crt_*.jpg; do sz=$(stat -c %s "$f"); [ "$sz" -gt "$bs" ] && { bs=$sz; best=$f; }; done
	b=${d##*/}
	"$S/square.sh" "$best" "$O/crt/$b.jpg"
	i=$((i+1)); k=$(printf %02d $i)
	convert "$O/crt/$b.jpg" -resize 480x -gravity north -background black -splice 0x34 -fill white -pointsize 24 -annotate +0+4 "$k  $b" "$O/lab/$k.jpg"
done
montage "$O"/lab/*.jpg -tile 4x -geometry +4+4 -background '#222' "$O/crt_list.jpg"
