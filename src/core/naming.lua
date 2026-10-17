-- Screenshot names and the "why" text shown in the panel. Pure.
local Naming = {}

-- Keep file names safe on every OS: letters, digits, dash, underscore.
function Naming.safe(text)
  local cleaned = tostring(text or ""):gsub("[^%w%-_ ]", ""):gsub("%s+", "-")
  return cleaned ~= "" and cleaned or "player"
end

---@param reason table { kind = "level"|"broadcast"|"drop", skillName?, level? }
function Naming.describe(reason)
  if reason.kind == "level" then return "Level " .. reason.level .. " " .. reason.skillName end
  if reason.kind == "drop" then return "Rare drop" end
  return "Broadcast"
end

-- "6ing_Level-99-Fishing_0007.png"
function Naming.fileName(playerName, reason, counter)
  return string.format("%s_%s_%04d.png", Naming.safe(playerName), Naming.safe(Naming.describe(reason)), counter)
end

return Naming
