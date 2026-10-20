-- Persistent settings and the screenshot counter. The db is injectable for tests.
local Triggers = require("src/core/triggers")

local Store = {}
Store.__index = Store

Store.KEY = "auto-screenshot-settings"

local function isBool(v) return type(v) == "boolean" end
local function isFolder(v) return type(v) == "string" and #v <= 260 end
local function isCount(v) return type(v) == "number" and v >= 0 and v == math.floor(v) end
local function isMode(v)
  for _, mode in ipairs(Triggers.LEVEL_MODES) do if mode.id == v then return true end end
  return false
end

local SETTINGS = {
  levelMode = { default = "99_120", valid = isMode },
  broadcasts = { default = true, valid = isBool },
  rareDrops = { default = true, valid = isBool },
  achievements = { default = true, valid = isBool },
  folder = { default = "", valid = isFolder },
  counter = { default = 0, valid = isCount },
}

function Store.new(db)
  local self = setmetatable({ settings = {} }, Store)
  self.db = db or rawget(_G, "PersistentDB")
  local raw
  if self.db then
    local ok, value = pcall(function() return self.db:GetStructuredData(Store.KEY) end)
    if ok then raw = value end
  end
  raw = type(raw) == "table" and raw or {}
  for name, spec in pairs(SETTINGS) do
    -- Not `valid and value or default`: that idiom turns a saved `false` back into the default.
    if spec.valid(raw[name]) then self.settings[name] = raw[name] else self.settings[name] = spec.default end
  end
  return self
end

function Store:get(name)
  return self.settings[name]
end

function Store:set(name, value)
  local spec = SETTINGS[name]
  if not spec or not spec.valid(value) then return false end
  self.settings[name] = value
  if self.db then
    local ok, err = pcall(function() return self.db:SetStructuredData(Store.KEY, self.settings) end)
    if not ok and log then log("[auto-screenshot] save failed: " .. tostring(err)) end
  end
  return true
end

function Store:nextCounter()
  local value = self.settings.counter + 1
  self:set("counter", value)
  return value
end

return Store
