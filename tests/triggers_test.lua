local A = require("assert")
local Triggers = require("src/core/triggers")
local Naming = require("src/core/naming")
local Skills = require("src/core/skills")
local PATTERNS = require("src/data/patterns")

local T = {}
local m = Triggers.levelMatches

function T.all_levels_mode()
  A.eq(m("all", 1, 2), true); A.eq(m("all", 98, 99), true); A.eq(m("all", 110, 111), true)
  A.eq(m("all", 50, 50), false, "no change"); A.eq(m("all", 50, 49), false, "drain/never a level-up")
end

function T.only_99s()
  A.eq(m("99", 98, 99), true); A.eq(m("99", 97, 99), true, "lamp jump to 99")
  A.eq(m("99", 97, 100), true, "jump past 99"); A.eq(m("99", 99, 100), false, "virtual 100")
  A.eq(m("99", 50, 51), false); A.eq(m("99", 119, 120), false)
end

function T.only_120s()
  A.eq(m("120", 119, 120), true); A.eq(m("120", 118, 121), true)
  A.eq(m("120", 98, 99), false); A.eq(m("120", 120, 121), false)
end

function T.ninety_nines_and_one_twenties()
  A.eq(m("99_120", 98, 99), true); A.eq(m("99_120", 119, 120), true)
  A.eq(m("99_120", 50, 51), false); A.eq(m("99_120", 100, 101), false)
end

function T.only_broadcasts_skips_level_ups()
  A.eq(m("broadcasts", 98, 99), false); A.eq(m("broadcasts", 119, 120), false)
end

function T.five_modes_in_order()
  local labels = {}
  for i, mode in ipairs(Triggers.LEVEL_MODES) do labels[i] = mode.label end
  A.list(labels, { "All levels", "Only 99s", "Only 120s", "99s & 120s", "Only broadcasts" })
end

function T.login_snapshot_is_only_a_baseline()
  local t = Triggers.new(PATTERNS)
  A.eq(#t:levelChanges({ [0] = 99, [10] = 98 }), 0, "logging in never fires")
  local changes = t:levelChanges({ [0] = 99, [10] = 99 })
  A.eq(#changes, 1); A.eq(changes[1].skill, 10); A.eq(changes[1].old, 98); A.eq(changes[1].new, 99)
  A.eq(#t:levelChanges({ [0] = 99, [10] = 99 }), 0, "no repeat")
end

function T.missing_levels_ignored()
  local t = Triggers.new(PATTERNS)
  t:levelChanges({ [0] = 50 })
  A.eq(#t:levelChanges({ [0] = 51, [1] = 10 }), 1, "a skill with no previous value is not a level-up")
end

function T.own_broadcast_detected()
  local t = Triggers.new(PATTERNS)
  A.eq(t:chatKind("News: 6ing has achieved level 99 in Fishing!", "6ing"), "broadcast")
  A.eq(t:chatKind("<col=ff0000>News: 6ING received a drop: Dragon rider lance</col>", "6ing"), "broadcast", "colour tags and case")
end

function T.other_players_broadcasts_ignored()
  local t = Triggers.new(PATTERNS)
  A.eq(t:chatKind("News: Zezima received a drop: Dragon rider lance", "6ing"), nil)
  A.eq(t:chatKind("News: 6ing received a drop", nil), nil, "unknown own name never matches")
end

function T.rare_drop_messages()
  local t = Triggers.new(PATTERNS)
  A.eq(t:chatKind("A golden beam shines over one of your items.", "6ing"), "drop")
  A.eq(t:chatKind("You have a funny feeling like you're being followed.", "6ing"), "drop")
  A.eq(t:chatKind("You catch a shark.", "6ing"), nil); A.eq(t:chatKind("", "6ing"), nil); A.eq(t:chatKind(nil, "6ing"), nil)
end

function T.merge_window()
  local t = Triggers.new(PATTERNS)
  A.eq(t:shouldCapture(10), true); A.eq(t:shouldCapture(12), false, "the 99's broadcast, 2 ticks later")
  A.eq(t:shouldCapture(14), false); A.eq(t:shouldCapture(15), true, "a separate moment")
end

function T.skill_names()
  A.eq(Skills.name(0), "Attack"); A.eq(Skills.name(3), "Constitution"); A.eq(Skills.name(10), "Fishing")
  A.eq(Skills.name(28), "Necromancy"); A.eq(Skills.name(40, { NEW_SKILL = 40 }), "New skill")
  A.eq(Skills.name(41), "Skill 41")
end

function T.file_names()
  A.eq(Naming.fileName("6ing", { kind = "level", skillName = "Fishing", level = 99 }, 7), "6ing_Level-99-Fishing_0007.png")
  A.eq(Naming.fileName("Mr. Bob*", { kind = "drop" }, 12), "Mr-Bob_Rare-drop_0012.png")
  A.eq(Naming.fileName(nil, { kind = "broadcast" }, 1), "player_Broadcast_0001.png")
end

return T
