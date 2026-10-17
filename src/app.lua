-- Watches levels and chat, and takes a screenshot for each moment that matches the settings.
local Triggers = require("src/core/triggers")
local Skills = require("src/core/skills")
local Naming = require("src/core/naming")
local Capture = require("src/game/capture")

local App = {}
App.__index = App

local EVENT_ID = "auto-screenshot:watch"
App.MAX_HISTORY = 10

function App.new(store, patterns)
  return setmetatable({
    store = store, triggers = Triggers.new(patterns), tick = 0, history = {}, listeners = {},
  }, App)
end

function App:onChange(key, fn)
  self.listeners[key] = fn
  if fn then pcall(fn, self) end
end

function App:_notify()
  for _, fn in pairs(self.listeners) do pcall(fn, self) end
end

local function playerName()
  local ok, name = pcall(function() return Player.GetEntity().displayName or PlayerList.Self().displayName end)
  if ok then return name end
  return nil
end

local function readLevels()
  local ok, levels = pcall(function()
    if not Player.IsAvailable() then return nil end
    local list = {}
    for skill = Skills.FIRST, Skills.LAST do list[skill] = Player.GetLevelUncapped(skill) end
    return list
  end)
  if ok then return levels end
  return nil
end

function App:_record(reason, captured, detail)
  table.insert(self.history, 1, { text = Naming.describe(reason), captured = captured, detail = detail })
  while #self.history > App.MAX_HISTORY do table.remove(self.history) end
  self:_notify()
end

-- One moment -> one screenshot (nearby triggers are merged).
function App:_moment(reason)
  if not self.triggers:shouldCapture(self.tick) then return end
  local fileName = Naming.fileName(playerName(), reason, self.store:nextCounter())
  Capture.take(fileName, self.store:get("folder"), function(ok, detail)
    self:_record(reason, ok, ok and detail or detail)
  end)
end

function App:_checkLevels()
  local levels = readLevels()
  if not levels then return end
  local mode = self.store:get("levelMode")
  for _, change in ipairs(self.triggers:levelChanges(levels)) do
    if Triggers.levelMatches(mode, change.old, change.new) then
      local skillType = rawget(_G, "SkillType")
      self:_moment({ kind = "level", skillName = Skills.name(change.skill, skillType), level = change.new })
    end
  end
end

function App:onChat(event)
  local kind = self.triggers:chatKind(event and event.chatMessage, playerName())
  if kind == "broadcast" and self.store:get("broadcasts") then self:_moment({ kind = "broadcast" }) end
  if kind == "drop" and self.store:get("rareDrops") then self:_moment({ kind = "drop" }) end
end

function App:onTick()
  self.tick = self.tick + 1
  self:_checkLevels()
end

function App:start()
  Event.ServerLogic.Subscribe(EVENT_ID, function() self:onTick() end)
  Event.ChatMessage.Subscribe(EVENT_ID, function(event) self:onChat(event) end)
end

function App:stop()
  pcall(Event.ServerLogic.Unsubscribe, EVENT_ID)
  pcall(Event.ChatMessage.Unsubscribe, EVENT_ID)
  self.listeners = {}
end

return App
