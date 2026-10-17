-- Chat text that triggers a screenshot. Lowercase; colour tags are stripped before matching.
-- These are RS3's known wordings; confirm them in game and add any that are missing.
return {
  -- Game-wide broadcasts start like this; only ones that mention your own name count.
  broadcastPrefixes = { "news:" },
  -- Messages only you see when something rare drops.
  rareDrops = {
    "a golden beam shines over one of your items",
    "you have a funny feeling like you're being followed",
    "you feel something weird sneaking into your backpack",
  },
  -- Achievement completed. The pop-up says "Achievement Complete!"; the chat wording is not
  -- documented, so these cover the likely phrasings. Confirm in game.
  achievements = {
    "achievement complete",
    "completed the achievement",
    "completed an achievement",
  },
}
