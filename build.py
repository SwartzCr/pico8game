import math, random

S = {}
S[1] = """
..444...
..fff...
..ccc666
.fccc...
..ccc...
..1.1...
..1.1...
.44.44..
"""
S[2] = """
..444...
..fff...
..ccc666
..cccf..
..ccc...
...11...
...11...
..444...
"""
# player facing down (front view); walk cycle = horizontal flip
S[11] = """
..4444..
.444444.
.41ff14.
..ffff..
.cccccc.
fcc66ccf
..1664..
.4466...
"""
# player facing up (back view), sprayer raised over the head
S[12] = """
...66...
..4664..
.f4444f.
.c4444c.
.cccccc.
..cccc..
..1..4..
.44.....
"""
# power-up: menthol drop (speed) - lightning bolt on a mint candy
S[13] = """
..3333..
.333a33.
333aa333
33aaaa33
3333aa33
333aa333
.33a333.
..3333..
"""
# power-up: tissue shield (invulnerability)
S[14] = """
.cccccc.
ccc77ccc
c777777c
ccc77ccc
ccc77ccc
.cc77cc.
..cccc..
...cc...
"""
# power-up: saline refill (rapid fire) - three spray shots
S[15] = """
........
1ccc..7c
........
1ccc..7c
........
1ccc..7c
........
........
"""
# dust bunny
S[3] = """
.6....6.
.65..56.
.666666.
66066066
66666666
.666666.
.6.66.6.
6..55..6
"""
S[4] = """
.6....6.
.65..56.
.666666.
66066066
66666666
.666666.
6.6..6.6
..5..5..
"""
# pollen puff
S[5] = """
...a....
.a.9a.a.
..aaaa..
aa0aa0aa
..aaaa..
.a.99.a.
...a....
........
"""
S[6] = """
.a....a.
..a99a..
.aaaaaa.
.a0aa0a.
.aaaaaa.
..a99a..
.a....a.
........
"""
# dust mite
S[7] = """
.2....2.
..2..2..
.888888.
88788788
88888888
.888888.
2.2..2.2
2......2
"""
S[8] = """
2......2
.2....2.
.888888.
88788788
88888888
.888888.
.2.22.2.
2......2
"""
# booger king
S[9] = """
.a.a.a..
.aaaaa..
.bbbbbb.
bb0bb0bb
bbbbbbbb
b3bbbb3b
.b3333b.
..b..b..
"""
S[10] = """
.a.a.a..
.aaaaa..
.bbbbbb.
bb0bb0bb
bbbbbbbb
b3bbbb3b
.b3333b.
.b....b.
"""
# follicle (maze pillar)
S[18] = """
.4.44.4.
..4444..
.ee44ee.
eeeeee8e
e7eeee88
eeeee888
.e8888e.
..eeee..
"""
# fleshy border
S[19] = """
e8eeee8e
eeee8eee
8eee2ee8
ee8eeeee
eeeee8e2
e2eeeeee
eee8ee8e
8eeeeee8
"""

def grid(s):
    rows = [r for r in s.strip("\n").split("\n")]
    return [[c for c in r.ljust(8, ".")] for r in rows]

def hair_v(seed):
    r = random.Random(seed)
    g = [["."] * 8 for _ in range(8)]
    for base in (1, 4, 6):
        ph = r.random() * 6.28
        for y in range(8):
            x = base + round(math.sin(y / 8 * 6.28 + ph) * 0.9)
            x = max(0, min(7, x))
            g[y][x] = "4"
            if x + 1 < 8 and g[y][x + 1] == "." and r.random() < 0.55:
                g[y][x + 1] = "9"
    return g

def transpose(g):
    return [[g[x][y] for x in range(8)] for y in range(8)]

sprites = {k: grid(v) for k, v in S.items()}
sprites[16] = hair_v(3)
sprites[20] = hair_v(11)
sprites[17] = transpose(hair_v(5))
sprites[21] = transpose(hair_v(17))
# follicle junction: tangle of crossing hairs around a small pink root
fv, fh = hair_v(23), transpose(hair_v(29))
fol = [[fv[y][x] if fv[y][x] != "." else fh[y][x] for x in range(8)] for y in range(8)]
for y, row in enumerate([".ee.", "e7e8", "ee88", ".88."]):
    for x, c in enumerate(row):
        if c != ".":
            fol[y + 2][x + 2] = c
sprites[18] = fol

pix = [["0"] * 128 for _ in range(128)]
for n, g in sprites.items():
    sx, sy = (n % 16) * 8, (n // 16) * 8
    for y in range(8):
        for x in range(8):
            c = g[y][x]
            pix[sy + y][sx + x] = "0" if c == "." else c
gfx = "\n".join("".join(r) for r in pix[:32])

# --- sfx: (speed, [(pitch, wave, vol, fx), ...])
def sfx(speed, notes):
    s = "00%02x0000" % speed
    for n in notes[:32]:
        s += "%02x%x%x%x" % n
    s += "00000" * (32 - len(notes))
    return s

def seq(pitches, wave, vols, fx=0):
    if isinstance(vols, int):
        vols = [vols] * len(pitches)
    return [(p, wave, v, fx) for p, v in zip(pitches, vols)]

sfxs = [
    sfx(2, seq([48, 44, 40, 36, 32, 28], 4, [5, 5, 4, 4, 3, 2])),          # 0 shoot
    sfx(3, seq([36, 30, 26, 22, 18, 14, 12, 10], 6, [7, 7, 6, 5, 4, 3, 2, 1])),  # 1 kill
    sfx(5, seq(list(range(40, 12, -2)), 2, [6]*8 + [5, 4, 3, 2, 2, 1])),    # 2 die
    sfx(6, seq(list(range(10, 58, 2)), 7, 5, 1)),                          # 3 slurp
    sfx(8, seq([10, 8, 12, 9, 14, 10, 8, 6], 6, [7, 7, 7, 6, 6, 5, 3, 1])),  # 4 snort
    sfx(6, seq([30, 32, 34, 0, 34, 36, 38, 0], 0, [4, 4, 4, 0, 5, 5, 5, 0])
           + seq([44, 34, 24, 18, 14, 10, 8], 6, [7, 7, 7, 6, 4, 2, 1])),   # 5 achoo
    sfx(3, seq([24, 28, 32, 36], 0, 3)),                                   # 6 spawn
    sfx(8, seq([36, 31] * 5, 3, 4)),                                       # 7 boss
    sfx(2, seq([30, 26, 22, 18], 2, 4)),                                   # 8 enemy shot
    sfx(4, seq([36, 40, 43, 48, 43, 48], 0, 5)),                           # 9 extra life
    sfx(3, seq([34, 28, 31, 22], 2, [6, 5, 4, 2])),                         # 10 ouch
    sfx(3, seq([24, 28, 31, 36, 40, 43, 48], 1, 5)),                       # 11 power-up
    sfx(4, seq([36, 31, 28, 24], 1, [4, 3, 2, 1])),                          # 12 power-down
    sfx(1, seq([40], 1, [2])),                                              # 13 typewriter tick
]

lua = open("game.lua").read()
cart = (
    "pico-8 cartridge // http://www.pico-8.com\nversion 41\n__lua__\n"
    + lua.rstrip() + "\n__gfx__\n" + gfx + "\n__sfx__\n" + "\n".join(sfxs) + "\n"
)
open("wizards_of_snort.p8", "w").write(cart)

# preview sprite sheet
from PIL import Image
PAL = ["000000","1d2b53","7e2553","008751","ab5236","5f574f","c2c3c7","fff1e8",
       "ff004d","ffa300","ffec27","00e436","29adff","83769c","ff77a8","ffccaa"]
im = Image.new("RGB", (128, 32))
for y in range(32):
    for x in range(128):
        im.putpixel((x, y), tuple(int(PAL[int(pix[y][x], 16)][i:i+2], 16) for i in (0, 2, 4)))
im.crop((0, 0, 128, 24)).resize((128*8, 24*8), Image.NEAREST).save("sheet.png")
print("ok", len(lua), "chars")
