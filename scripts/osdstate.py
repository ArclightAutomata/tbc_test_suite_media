#!/usr/bin/env python3
"""osdstate.py <frame> : classify the MiSTer OSD in a 1920x1080 HDMI frame.

Prints one of:
  CLOSED
  MAIN <row>   main menu, cursor on row 0-7
  P<n> <row>   submenu n (1-4); row = highlighted row index or -1
Title strip compared against reference frames in ref/; cursor found as
the brightest row band (the highlight bar is light pink).
"""
import os, subprocess, sys

W, H = 1920, 1080
HERE = os.path.dirname(os.path.abspath(__file__))
REFS = {"MAIN": "MAIN0.png", "P1": "P1.png", "P2": "P2.png", "P3": "P3.png", "P4": "P4.png"}
# row centre y for the first rows of every menu (same pitch at the top)
MAIN_ROWS = [332, 396, 460, 524, 587, 651, 683, 715]

def gray(path):
    out = subprocess.run(["ffmpeg", "-loglevel", "error", "-i", path, "-vf", "format=gray",
                          "-f", "rawvideo", "-"], capture_output=True, check=True).stdout
    assert len(out) == W * H, f"{path}: not 1920x1080"
    return out

def region(img, x0, x1, y0, y1, step=2):
    return [img[y * W + x] for y in range(y0, y1, step) for x in range(x0, x1, step)]

def strip(img):
    return region(img, 587, 631, 305, 775)

def mad(a, b):
    return sum(abs(p - q) for p, q in zip(a, b)) / len(a)

def band(img, y):
    v = region(img, 700, 1250, y - 6, y + 6, 3)
    return sum(v) / len(v)

def main():
    img = gray(sys.argv[1])
    s = strip(img)
    scores = {k: mad(s, strip(gray(os.path.join(HERE, "ref", f)))) for k, f in REFS.items()}
    best = min(scores, key=scores.get)
    if scores[best] > 25:
        print("CLOSED"); return
    if best == "MAIN":
        b = [band(img, y) for y in MAIN_ROWS]
        print("MAIN", b.index(max(b)))
    else:
        top = band(img, 332)
        others = [band(img, y) for y in (396, 460, 524, 587)]
        print(best, 0 if top > max(others) + 30 else -1)

main()
