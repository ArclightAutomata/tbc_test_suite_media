# TBC Test Suite media

Photos, clips and animations of the [TBC Test Suite](https://github.com/ArclightAutomata/tbc_test_suite) MiSTer core on a CRT, plus the scripts that made them. The core's README hotlinks the animations in `anim/`; everything else is the source material, kept here so the README images can be re-picked or rebuilt.

Captured 2026-11-06 from core build 424679d: MiSTer Pi → MikeS11 adapter (S-Video) → Pelco PMCS15A CRT monitor, filmed with the camera shutter at 1/30 s.

| Folder | Contents |
|---|---|
| `anim/` | The README animations: animated WebP, 480×360, 15 fps, looping (Picture Roll: Slow Down, Flagwaving: Severe, Wow: Deep) |
| `clips/` | The source CRT clips for those animations |
| `retake_frames/` | The 92-step screenshot pass: per step, the OSD crop, one HDMI frame and six CRT frames |
| `squared_stills/` | Perspective-corrected 1200×900 stills used for the README galleries |
| `scripts/` | The tools below |

## Scripts

- `square.sh in.jpg out.jpg` — straightens one camera frame into an upright 4:3 picture. The camera can't sit square to the tube, so the four corners of the raster are measured with `edges.py frame.jpg 35` on a Logo frame and written into the script.
- `make_anim.sh clip.mp4 out.webp <start s> <frames>` — clip to squared, denoised animated WebP. The animations in `anim/` came from:
  - `make_anim.sh clips/roll_slow_down.mp4 anim/roll.webp 0.3 66`
  - `make_anim.sh clips/wow_deep.mp4 anim/wow.webp 0.3 60`
  - `make_anim.sh clips/flag_severe.mp4 anim/flagwave.webp 1 32`
- `gallery.py` — the captioned photo grids in the core's README. `make_shots.sh` and `sheet.py` make numbered contact sheets for picking shots.
- `sweep.sh`, `retake.sh`, `retake2.sh`, `osdstate.py` — drive the core's OSD over ssh (MiSTer_Batch_Control) and capture each step. Every menu state is read back from the HDMI capture before the next step. These are specific to this rig: an ssh host named `mister`, the CRT camera on `/dev/video10` and HDMI capture on `/dev/video11`.

If the camera moves, re-measure the corners and update both `square.sh` and `make_anim.sh`.

## License

GPL-2.0-or-later, the same as the core. See [LICENSE](LICENSE).

Copyright © 2026 Abe Voelker.
