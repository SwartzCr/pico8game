# Wizards of Snort

A PICO-8 maze shooter in the spirit of *Wizard of Wor*. A tiny explorer gets
snorted up a straw into a giant nose, and has to clear nose-hair mazes of dust
monsters.

![screenshots](screenshots.png)

## Play

Open `wizards_of_snort.p8` in PICO-8 and type `run` (or drag the file onto the
PICO-8 window).

- Arrow keys: move
- X / Z: fire saline spray (one shot on screen at a time)

| Monster     | Points | Notes                                        |
|-------------|--------|----------------------------------------------|
| Dust bunny  | 100    | slow                                         |
| Pollen puff | 200    | faster, smarter                              |
| Dust mite   | 500    | invisible unless you're close                |
| Booger King | 2500   | appears after each wave, escapes after 10 s  |

Extra life every 10,000 points. High score is saved.

## Files

- `wizards_of_snort.p8` — the cartridge (generated)
- `game.lua` — game source
- `build.py` — builds the cartridge: packs `game.lua` with the sprites and
  sound effects defined in Python (`python3 build.py`, needs Pillow for the
  sprite-sheet preview)
- `tools/harness.lua` — a minimal PICO-8 API stand-in for headless smoke tests
  and screenshots, run with a stock Lua 5.4:
  `lua tools/harness.lua wizards_of_snort.p8 smoke 1` or `... shots`

Tuning: monster speeds, chase behavior and points are in the `kt` table at the
top of `game.lua`.
