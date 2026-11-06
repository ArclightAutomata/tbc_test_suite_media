# gallery.py out.jpg cols tile_w file::caption ... : README photo grid
import sys
from PIL import Image, ImageDraw, ImageFont
out, cols, tw = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
items = [a.split('::') for a in sys.argv[4:]]
th = tw * 3 // 4; lab = 34; gap = 6
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 17)
rows = (len(items) + cols - 1) // cols
W = cols * tw + (cols + 1) * gap; H = rows * (th + lab) + (rows + 1) * gap - gap
sheet = Image.new('RGB', (W, H), (24, 24, 24)); d = ImageDraw.Draw(sheet)
for k, (f, cap) in enumerate(items):
    im = Image.open(f).convert('RGB').resize((tw, th), Image.LANCZOS)
    x = gap + (k % cols) * (tw + gap); y = gap + (k // cols) * (th + lab + gap)
    sheet.paste(im, (x, y))
    w = d.textlength(cap, font=font)
    d.text((x + (tw - w) / 2, y + th + 7), cap, fill=(232, 232, 232), font=font)
sheet.save(out, quality=84, optimize=True, progressive=True)
