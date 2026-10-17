# Auto Screenshot

An RS3 plugin that takes a screenshot of your big moments: level-ups, achievements, rare drops and your game broadcasts. Created by **6ing**. Version **1.0.0**.

Part of [6ing's RS3 plugins](https://github.com/6inq/rs3-plugins).

## What it captures
- **Level-ups**, using one of five options:
  - **All levels**
  - **Only 99s**
  - **Only 120s**
  - **99s & 120s** (default)
  - **Only broadcasts**: no level-up screenshots unless the game broadcasts them
- **Your game broadcasts**: `News:` messages that mention your name, such as rare drops, 99s and 120s. Other players' broadcasts are ignored.
- **Rare drop messages**: the golden loot beam and pet messages.
- **Achievements**: each completed achievement. The name goes in the file name when the game says it, e.g. `6ing_Achievement-Into-the-Abyss_0003.png`.
- A 99 also sends a broadcast. Moments within 3 seconds of each other are merged, so each gives **one** screenshot.
- Lamp jumps count (97 to 99 is still a 99). Logging in never triggers anything.

## Save location
Choose a folder in the settings, or leave it empty for the game's default screenshot folder. Files are named like `6ing_Level-99-Fishing_0007.png`; the number keeps counting across sessions.

## Status: waiting on Jagex's screenshot API
Jagex has not given plugins a way to take screenshots or save files. None of the plugins on mod.io can do either. Everything else is built and tested.
- Capturing lives in one file, `src/game/capture.lua`, to wire up once the API exists.
- Until then, the panel (ribbon icon) lists each moment it **would** have captured. You can check the triggers in game today.

The broadcast, rare-drop and achievement wordings are in `src/data/patterns.lua`. The achievement chat wording isn't documented anywhere, so it matches the likely phrasings. Confirm them in game and add any that are missing.

## Fair play
Auto Screenshot only watches your own levels and chat and takes pictures. It never acts in game.

## Layout
```
plugin.json, main.lua     entry point and manifest (requires PrettyUI)
src/core/triggers.lua     pure: level options, broadcast/drop matching, merging
src/core/skills.lua       skill ids -> names (Attack .. Necromancy)
src/core/naming.lua       file names and panel text
src/core/store.lua        settings and the screenshot counter
src/game/capture.lua      the one file to finish when the screenshot API exists
src/data/patterns.lua     broadcast and rare-drop wordings
src/ui/                   ribbon panel (recent moments) and settings
```

## Tests
Install the test dependency:
```bash
python -m pip install lupa
```

Then run the suite:
```bash
python tests/run.py
```

The suite has 35 tests:
- every level option against real transitions: lamp jumps, virtual levels 100+, 120s
- your broadcasts vs other players', with colour tags removed
- rare drops, achievements (with and without a name) and merging of near-simultaneous moments
- a full boot of `main.lua`, including:
  - the screenshot flow, with and without a camera
  - the save folder and file names
  - the counter continuing after a restart
  - the settings
  - a failing camera that reports the error instead of crashing

## Building
```bash
python tools/build.py
```
The output is `dist/auto-screenshot-1.0.0.zip`.
