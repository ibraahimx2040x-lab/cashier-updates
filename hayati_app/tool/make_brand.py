"""Draws Sanad's brand images (same mark as SanadMark in splash_screen.dart).

The mark is the letter S drawn as the sun's path: the upper bowl is the
day's arc, the lower bowl its return, and a saffron sun sits where the
day begins.

Run: python3 tool/make_brand.py  → assets/brand/*.png
Then: dart run flutter_launcher_icons && dart run flutter_native_splash:create
"""
import math

from PIL import Image, ImageDraw

INK = (0x1F, 0x27, 0x66)
SKY = (0x2F, 0x6D, 0xAE)
SAFFRON = (0xE0, 0x9A, 0x2F, 255)
WHITE = (255, 255, 255, 255)
SS = 4  # supersampling for smooth edges


def s_path(cx, cy, size):
    """Points of the S, `size` = full letter height. Two bowls of radius r,
    stacked, joined at the centre."""
    r = size / 4
    pts = []
    # Upper bowl: from 48° (upper right) over the top to 270°; the sun
    # waits just past its start, separated by a gap.
    for i in range(361):
        a = math.radians(48 + (270 - 48) * i / 360)
        pts.append((cx + r * math.cos(a), cy - r - r * math.sin(a)))
    # Lower bowl: from 90° (its top, the centre of the letter) clockwise to -160°.
    for i in range(361):
        a = math.radians(90 - (90 + 160) * i / 360)
        pts.append((cx + r * math.cos(a), cy + r - r * math.sin(a)))
    sun = (cx + r * math.cos(math.radians(8)), cy - r - r * math.sin(math.radians(8)))
    return pts, sun


def mark(size, scale, bg):
    """`bg`: None (transparent) or 'tile' (sky gradient). `scale`: letter
    height / size."""
    n = size * SS
    if bg == "tile":
        img = Image.new("RGBA", (n, n))
        top, bot = INK, SKY
        px = img.load()
        for y in range(n):
            t = y / (n - 1)
            col = tuple(int(top[k] + (bot[k] - top[k]) * t) for k in range(3)) + (255,)
            for x in range(n):
                px[x, y] = col
    else:
        img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    h = n * scale
    w = h * 0.17
    pts, sun = s_path(n / 2, n / 2, h)
    for x, y in pts:  # stroke by stamping discs: smooth joints
        d.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2], fill=WHITE)
    sr = w * 0.78
    d.ellipse([sun[0] - sr, sun[1] - sr, sun[0] + sr, sun[1] + sr], fill=SAFFRON)
    return img.resize((size, size), Image.LANCZOS)


if __name__ == "__main__":
    out = "assets/brand"
    mark(1024, 0.56, "tile").save(f"{out}/icon.png")          # full-bleed app icon
    mark(1024, 0.38, None).save(f"{out}/icon_foreground.png")  # Android adaptive (66% safe zone)
    mark(768, 0.42, None).save(f"{out}/splash.png")            # centred on the ink splash
    print("ok")
