local Triggers = {}
Triggers.__index = Triggers

Triggers.LEVEL_MODES = {
  { id = "all", label = "All levels" },
  { id = "99", label = "Only 99s" },
  { id = "120", label = "Only 120s" },
  { id = "99_120", label = "99s & 120s" },
  { id = "broadcasts", label = "Only broadcasts" },
}

Triggers.MERGE_TICKS = 5

local function crossed(old, new, target)
  return old < target and new >= target
end

function Triggers.levelMatches(mode, old, new)
  if new <= old then return false end
  if mode == "all" then return true end
  if mode == "99" then return crossed(old, new, 99) end
  if mode == "120" then return crossed(old, new, 120) end
  if mode == "99_120" then return crossed(old, new, 99) or crossed(old, new, 120) end
  return false
end

function Triggers.new(patterns)
  return setmetatable({ patterns = patterns, levels = nil, lastCaptureTick = nil }, Triggers)
end

function Triggers:levelChanges(levels)
  local changes = {}
  if self.levels then
    for skill, new in pairs(levels) do
      local old = self.levels[skill]
      if type(old) == "number" and type(new) == "number" and new > old then
        changes[#changes + 1] = { skill = skill, old = old, new = new }
      end
    end
  end
  self.levels = levels
  table.sort(changes, function(a, b) return a.skill < b.skill end)
  return changes
end

local function startsWithAny(text, prefixes)
  for _, prefix in ipairs(prefixes) do
    if text:sub(1, #prefix) == prefix then return true end
  end
  return false
end

local function containsAny(text, needles)
  for _, needle in ipairs(needles) do
    if text:find(needle, 1, true) then return true end
  end
  return false
end

local function plain(message)
  return (tostring(message or ""):gsub("<[^>]*>", "")):lower()
end

local function achievementName(text, original)
  local start = text:find("achievement[^:]*:")
  if not start then return nil end
  local raw = tostring(original or ""):gsub("<[^>]*>", "")
  local name = raw:match("[Aa]chievement[^:]*:%s*(.-)%s*[!%.]*$")
  if name and name ~= "" then return name end
  return nil
end

function Triggers:chatKind(message, playerName)
  local text = plain(message)
  if text == "" then return nil end
  if startsWithAny(text, self.patterns.broadcastPrefixes) then
    local name = plain(playerName)
    if name ~= "" and text:find(name, 1, true) then return "broadcast" end
    return nil
  end
  if containsAny(text, self.patterns.rareDrops) then return "drop" end
  if containsAny(text, self.patterns.achievements or {}) then return "achievement", achievementName(text, message) end
  return nil
end

function Triggers:shouldCapture(tick)
  if self.lastCaptureTick and tick - self.lastCaptureTick < Triggers.MERGE_TICKS then return false end
  self.lastCaptureTick = tick
  return true
end

return Triggers
