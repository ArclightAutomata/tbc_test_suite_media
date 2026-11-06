#!/bin/bash
# Full OSD option sweep with closed-loop navigation: every move is
# decided from an HDMI snapshot of the OSD (osdstate.py), because the
# OSD sometimes reopens on the main menu and sometimes on the last
# submenu. Start state: anything; everything at factory defaults
# (Pattern = Logo).
S=$(dirname "$(readlink -f "$0")")
OUT=${OUT:-$S/sweep}
mkdir -p "$OUT"
LOG="$OUT/log.txt"
N=${START_N:-0}

rep() { local s=""; for ((i=0;i<$2;i++)); do s+="$1"; done; printf '%s' "$s"; }
# Leading Shift (:2a) absorbs the occasionally-lost first key of a call
mbc() { ssh mister "/media/fat/mbc raw_seq '!s:2a!s$1'"; }
snap() { ffmpeg -y -loglevel error -f v4l2 -i /dev/video11 -frames:v 1 -q:v 2 "$1"; }
state() { snap "$S/st.jpg"; python3 -I "$S/osdstate.py" "$S/st.jpg"; }
die() { echo "ABORT: $*" | tee -a "$LOG"; exit 2; }

# goto <sub 0-3> <item> <extra keys> : leave the cursor on <item> of
# submenu <sub>, then send <extra keys> in the same call
goto() {
	local sub=$1 item=$2 extra=$3 tries=0 st r keys
	while :; do
		tries=$((tries+1)); [ $tries -gt 4 ] && die "could not reach P$((sub+1)) item $item (last: $st)"
		st=$(state)
		case "$st" in
			CLOSED) mbc "M"; sleep 1.3; continue ;;
			MAIN*)  r=${st#MAIN }
			        if [ "$r" -le "$sub" ]; then keys=$(rep D $((sub-r))); else keys=$(rep U $((r-sub))); fi
			        keys+="O" ;;
			P*)     local n=${st:1:1}; r=${st#P? }
			        if [ "$n" -eq $((sub+1)) ] && [ "$r" -eq 0 ]; then keys=""
			        else mbc ":0e"; sleep 1.0; continue; fi ;;
		esac
		break
	done
	mbc "${keys}$(rep D $item)${extra}"
}

close_osd() {
	local i st
	for i in 1 2 3; do
		mbc "E"; sleep 1.0
		st=$(state); [ "$st" = CLOSED ] && return
	done
	die "OSD would not close (last: $st)"
}

set_opt() { goto "$1" "$2" "$(rep O $3)"; sleep 1.0; close_osd; }

# step <sub> <item> <label> : one Enter on the item, then capture
step() {
	local sub=$1 item=$2 label=$3
	N=$((N+1)); local d; d=$(printf '%s/%03d_%s' "$OUT" $N "$label"); mkdir -p "$d"
	goto "$sub" "$item" "O"
	sleep 1.2
	snap "$d/osd_full.jpg"
	local st; st=$(python3 -I "$S/osdstate.py" "$d/osd_full.jpg")
	ffmpeg -y -loglevel error -i "$d/osd_full.jpg" -vf "crop=800:540:560:270" "$d/osd.jpg" && rm "$d/osd_full.jpg"
	[ "${st%% *}" = "P$((sub+1))" ] || die "step $N ($label): expected P$((sub+1)) open, saw '$st'"
	close_osd
	sleep 1.0
	ffmpeg -y -loglevel error -f v4l2 -i /dev/video11 -frames:v 1 "$d/hdmi.jpg" &
	ffmpeg -y -loglevel error -f v4l2 -i /dev/video10 -t 1.6 -vf fps=4 -frames:v 6 "$d/crt_%d.jpg"
	wait
	echo "$(date +%T) $N $label" | tee -a "$LOG"
}

# sweep <sub> <item> <name> <values...> : the current value must be the
# first listed; cycles through all and back to the first
sweep() {
	local sub=$1 item=$2 name=$3; shift 3
	local vals=("$@") n=${#vals[@]}
	for ((k=1;k<=n;k++)); do
		local v=${vals[$((k % n))]}
		step "$sub" "$item" "${name}=${v// /_}"
	done
}

P1_PAT=(Logo Bars Crosshatch Grayscale Multiburst Solid Checker PLUGE Convergence Motion CustomVideo Analysis ModStaircase ModRamp PulseBar Window Mandelbrot)

timing_pass() {   # $1 = tag
	sweep 1 0  "$1VCR"     Off Good Worn EP Failing Damaged
	sweep 1 1  "$1Roll"    Off SlowUp SlowDown FastUp FastDown Drift
	sweep 1 2  "$1Tear"    Off Mild Moderate Severe Burst
	sweep 1 3  "$1Jitter"  Off Faint Light Typical Heavy
	sweep 1 4  "$1Flag"    Off Subtle Moderate Severe Fast Slow
	sweep 1 5  "$1Skew"    Off TopHeavy BotHeavy Moderate Severe
	sweep 1 6  "$1Wow"     Off Gentle Slow Typical Deep
	sweep 1 7  "$1Flutter" Off Typical Fast
	sweep 1 8  "$1Drop"    Off Light Moderate Heavy Stress Crease
	sweep 1 9  "$1DropComp" Off On
	sweep 1 10 "$1HeadSw"  Off Subtle Typical Severe Unstable
	sweep 1 11 "$1Heads"   Clean Dirty VeryDirty OneClogged BothClogged
	sweep 1 12 "$1Sweep"   Off WowDepth TearAmp FlagAmp JitterRMS
}

# clip <name> : 5 s of CRT video (for README GIFs)
clip() { ffmpeg -y -loglevel error -f v4l2 -i /dev/video10 -t 5 -c:v libx264 -crf 16 "$OUT/clip_$1.mp4"; }

[ -n "$ONLY" ] && { eval "$ONLY"; exit; }

echo "start $(date +%T)" | tee "$LOG"

# 1. every pattern (interlace on)
sweep 0 0 Pattern "${P1_PAT[@]}"

# 2. timing errors on Crosshatch
set_opt 0 0 2
timing_pass ""

# 3. encoding errors on Color Bars (Crosshatch -> Bars = 16 presses)
set_opt 0 0 16
sweep 2 0 Encoder   Custom FrameworkClone
sweep 2 1 Hue       Off p11 p45 p90 180 m45 Drift
sweep 2 2 Burst     100 50 25 Off Flicker
sweep 2 3 Subcar    Off p250Hz m250Hz p1k m1k p5k Drift
sweep 2 4 CDelay    Off 100ns 250ns 500ns 1us 2us 4.5us
sweep 2 5 CNoise    Off Mild Moderate Severe
sweep 2 6 CBW       Sharp Broadcast

# 4. advanced (Color Bars; seeds skipped)
sweep 3 2 Standard  NTSC PAL
sweep 3 3 Output    SVideo Composite
sweep 3 4 VBI       Off On
sweep 3 5 PulseX    Off Enhanced Raw
sweep 3 7 VLevel    Full Limited Medium Low
sweep 3 8 HDMIView  Clean EncodedRaw
sweep 3 9 VPos      Default Down2 Down4

# 5. interlace off: patterns + timing errors again
set_opt 3 6 1
sweep 0 0 IL0_Pattern "${P1_PAT[@]:1}" Logo
set_opt 0 0 1          # Bars -> Crosshatch
timing_pass "IL0_"
set_opt 3 6 1          # interlace back on
set_opt 0 0 15         # Crosshatch -> Logo

echo "done $(date +%T)" | tee -a "$LOG"
