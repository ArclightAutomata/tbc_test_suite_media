#!/bin/bash
# retake.sh : README screenshot pass. Start: factory defaults (Logo).
# Timing rows on Crosshatch, then presets + encoding rows on Color Bars,
# plus 5 s CRT clips of Roll Slow Down and Wow Deep for the GIFs.
S=$(dirname "$(readlink -f "$0")")
export OUT=${OUT:-$S/retake}
export ONLY='
set_opt 0 0 2
sweep 1 0  VCR     Off Good Worn EP Failing Damaged
sweep 1 1  Roll    Off SlowUp SlowDown FastUp FastDown Drift
sweep 1 2  Tear    Off Mild Moderate Severe Burst
sweep 1 3  Jitter  Off Faint Light Typical Heavy
sweep 1 4  Flag    Off Subtle Moderate Severe Fast Slow
sweep 1 5  Skew    Off TopHeavy BotHeavy Moderate Severe
sweep 1 6  Wow     Off Gentle Slow Typical Deep
sweep 1 8  Drop    Off Light Moderate Heavy Stress Crease
sweep 1 10 HeadSw  Off Subtle Typical Severe Unstable
sweep 1 11 Heads   Clean Dirty VeryDirty OneClogged BothClogged
set_opt 1 1 2; sleep 2; clip RollSlowDown; set_opt 1 1 4
set_opt 1 6 4; sleep 2; clip WowDeep;      set_opt 1 6 1
set_opt 0 0 16
sweep 1 0  Bars_VCR Off Good Worn EP Failing Damaged
sweep 2 1  Hue      Off p11 p45 p90 180 m45 Drift
sweep 2 2  Burst    100 50 25 Off Flicker
sweep 2 3  Subcar   Off p250Hz m250Hz p1k m1k p5k Drift
sweep 2 4  CDelay   Off 100ns 250ns 500ns 1us 2us 4.5us
sweep 2 5  CNoise   Off Mild Moderate Severe
sweep 2 6  CBW      Sharp Broadcast
set_opt 0 0 16
'
mkdir -p "$OUT"
bash "$S/sweep.sh"
