#!/bin/bash
# make_anim.sh <clip.mp4> <out.webp> <start s> <frames> : squared, denoised
# 480x360 animated WebP at 15 fps for the README. Corner values: square.sh.
set -e
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
ffmpeg -loglevel error -ss "$3" -i "$1" -vf fps=15 -frames:v "$4" -q:v 2 "$T/%03d.jpg"
for f in "$T"/*.jpg; do
	convert "$f" -virtual-pixel black -distort Perspective \
	 '625.9,121.9 40,30  1651.5,165.8 1160,30  613.5,913.8 40,870  1605.0,940.2 1160,870' \
	 -crop 1200x900+0+0 +repage -resize 480x360 "${f%.jpg}.png"
done
ffmpeg -y -loglevel error -framerate 15 -i "$T/%03d.png" -vf hqdn3d=6:6:8:8 \
	-c:v libwebp_anim -lossless 0 -q:v 60 -loop 0 "$2"
ls -la "$2"
