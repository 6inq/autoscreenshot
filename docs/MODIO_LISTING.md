# mod.io listing answers: Auto Screenshot

Copy each field into the mod.io "Create Plugin" form. You're making the listing image yourself (16:9, min 512x288, max 8MB).

---

## Basics

**Plugin name**
```
Auto Screenshot
```

**Summary** (250 character max; this is 211)
```
Automatically screenshots your big moments: level-ups (all, 99s, 120s, 99s & 120s, or broadcasts only), achievements, rare drops and your game broadcasts. Save to any folder. One moment, one screenshot. By 6ing.
```

**Homepage**
```
https://github.com/6inq/auto-screenshot
```

**Profile URL**
```
https://mod.io/g/runescape/m/auto-screenshot
```

**Community**
- Allow comments: **checked**
- Allow dependants: **unchecked**

---

## Description

Click the `<>` (source code) button in the editor toolbar and paste this:

```html
<p>Auto Screenshot captures your big moments automatically: level-ups, achievements, rare drops and your game broadcasts.</p>

<h2>Choose what to capture</h2>
<ul>
<li><strong>Level-ups:</strong> All levels, Only 99s, Only 120s, 99s &amp; 120s, or Only broadcasts.</li>
<li><strong>Your game broadcasts:</strong> rare drops, 99s, 120s and more. Other players' broadcasts are ignored.</li>
<li><strong>Rare drop messages:</strong> the golden loot beam and pet drops.</li>
<li><strong>Achievements:</strong> every achievement you complete, named in the file when the game shows the name.</li>
</ul>
<p>A 99 that is also broadcast gives you one screenshot, not two. Lamp jumps count too.</p>

<h2>Save where you want</h2>
<p>Pick a folder in the settings, or leave it empty for the game's default screenshot folder. Files are named by character, moment and number, like <em>6ing_Level-99-Fishing_0007.png</em>.</p>

<h2>Fair play</h2>
<p>Auto Screenshot only watches your own levels and chat and takes pictures. It never acts in game.</p>

<h2>Requires</h2>
<p><strong>PrettyUI</strong> (installed automatically).</p>

<p>Created by <strong>6ing</strong>. Free. Feedback welcome in the comments.</p>
```

---

## Tag selection

**Gameplay**: none

**Theme**
- Utility: **checked**
- Fun: **checked**

**Technical**
- Notification and Timers: **checked**

**Permissions**
- chatAccess: **check this if mod.io requires it for reading chat.** Quest Helper reads chat without declaring a permission, so it may not be needed. Confirm when Jagex's docs are out.
- Everything else: unchecked (until a screenshot or file permission exists)

**Mobile**
- Mobile UI friendly: **unchecked**

---

## Visibility
Start with **Private**, then switch to **Public** after testing in the live client.

## Before you submit
- [ ] Wire the real screenshot and save call into `src/game/capture.lua` once Jagex provides it.
- [ ] In game, check the panel lists level-ups, your broadcasts and rare drops (and ignores other players' broadcasts).
- [ ] Complete an achievement and check it shows in the panel; confirm the wordings in `src/data/patterns.lua`.
- [ ] Build with `python tools/build.py` and upload `dist/auto-screenshot-1.0.0.zip`.
- [ ] Upload your listing image.
