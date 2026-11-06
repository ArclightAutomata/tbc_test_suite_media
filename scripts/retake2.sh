#!/bin/bash
# retake2.sh : video takes of the banded shots and of Crease. Start: Logo, all errors off.
S=$(dirname "$(readlink -f "$0")")
export OUT=${OUT:-$S/retake2}
mkdir -p "$OUT"
export ONLY='
vid() { ffmpeg -y -loglevel error -f v4l2 -i /dev/video10 -t $2 -c:v libx264 -crf 14 "$OUT/$1.mp4"; echo "$(date +%T) $1"; }
set_opt 0 0 1
set_opt 2 2 2; sleep 2; vid Burst25 8;        set_opt 2 2 3
set_opt 2 6 1; sleep 2; vid CBW_Broadcast 8;  set_opt 2 6 1
set_opt 1 0 5; sleep 2; vid Bars_Damaged 8;   set_opt 1 0 1
set_opt 0 0 1
set_opt 1 0 4; sleep 2; vid VCR_Failing 8;    set_opt 1 0 2
set_opt 1 8 5; sleep 2; vid Crease 45;        set_opt 1 8 1
set_opt 0 0 15
'
bash "$S/sweep.sh"
