# sheet.py out.jpg cols tile_w file[:label] ...  - labeled contact sheet
import sys
from PIL import Image, ImageDraw, ImageFont
out, cols, tw = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
items = [a.split('::') for a in sys.argv[4:]]
ims = []
for it in items:
    im = Image.open(it[0]).convert('RGB')
    im = im.resize((tw, round(im.height * tw / im.width)), Image.LANCZOS)
    ims.append((im, it[1] if len(it) > 1 else ''))
th = max(i.height for i, _ in ims); lab = 22
rows = (len(ims) + cols - 1) // cols
sheet = Image.new('RGB', (cols * tw, rows * (th + lab)), (20, 20, 20))
d = ImageDraw.Draw(sheet)
try: font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 15)
except Exception: font = ImageFont.load_default()
for k, (im, l) in enumerate(ims):
    x, y = (k % cols) * tw, (k // cols) * (th + lab)
    sheet.paste(im, (x, y)); d.text((x + 6, y + th + 3), l, fill=(230, 230, 230), font=font)
sheet.save(out, quality=88)
