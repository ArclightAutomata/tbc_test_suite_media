#!/bin/bash
# square.sh in.jpg out.jpg : warp the CRT camera frame so the screen
# opening is an upright 4:3 rectangle, then crop to it plus a margin
# corners measured from the bezel (level/edges.py, threshold 35); target 1120x840 at (40,30)
convert "$1" -virtual-pixel black -distort Perspective \
 '625.9,121.9 40,30  1651.5,165.8 1160,30  613.5,913.8 40,870  1605.0,940.2 1160,870' \
 -crop 1200x900+0+0 +repage -quality 92 "$2"
