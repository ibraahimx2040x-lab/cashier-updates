"""Draws Hayati's brand images (same mark as HayatiLogo in splash_screen.dart).

Run: python3 tool/make_brand.py  → assets/brand/*.png
Then: dart run flutter_launcher_icons && dart run flutter_native_splash:create
"""
from PIL import Image, ImageDraw

GREEN = (0x16, 0x3A, 0x36, 255)
WHITE = (255, 255, 255, 255)
SS = 4  # supersampling for smooth edges


def mark(size, scale, bg):
    """Ring with a curved path and two dots; `scale` = mark diameter / size."""
    n = size * SS
    img = Image.new("RGBA", (n, n), bg)
    d = ImageDraw.Draw(img)
    c = n / 2
    r = n * scale / 2
    w = max(2, int(r * 2 * 0.07))
    ring = r * 0.86
    d.ellipse([c - ring, c - ring, c + ring, c + ring], outline=WHITE, width=w)
    # A winding S-shaped path (bottom-left → top-right) with a dot at each
    # end: "a connected path", deliberately not a straight diagonal.
    a = (c - r * 0.40, c + r * 0.36)
    m = (c, c)
    b = (c + r * 0.40, c - r * 0.36)
    def quad(p0, p1, p2, steps=400):
        return [((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0],
                 (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1])
                for t in (i / steps for i in range(steps + 1))]
    pts = quad(a, (c + r * 0.05, c + r * 0.50), m) + quad(m, (c - r * 0.05, c - r * 0.50), b)
    # Stroke by stamping discs: smooth joints at any thickness.
    for x, y in pts:
        d.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2], fill=WHITE)
    for p in (a, b):
        dr = r * 0.11
        d.ellipse([p[0] - dr, p[1] - dr, p[0] + dr, p[1] + dr], fill=WHITE)
    return img.resize((size, size), Image.LANCZOS)


if __name__ == "__main__":
    out = "assets/brand"
    mark(1024, 0.62, GREEN).save(f"{out}/icon.png")                 # full-bleed app icon
    mark(1024, 0.42, (0, 0, 0, 0)).save(f"{out}/icon_foreground.png")  # Android adaptive (66% safe zone)
    mark(768, 0.5, (0, 0, 0, 0)).save(f"{out}/splash.png")          # centred on green splash
    print("ok")
