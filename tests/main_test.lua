-- Boots main.lua with a stubbed client: levels rise, broadcasts arrive, screenshots happen.
local A = require("assert")
local Store = require("src/core/store")

local T = {}

local function memoryDb()
  local db = { data = {} }
  function db:GetStructuredData(key) return self.data[key] end
  function db:SetStructuredData(key, value) self.data[key] = value end
  return db
end

local function boot(opts)
  opts = opts or {}
  local env = { events = {}, panels = {}, settings = {}, shots = {}, levels = {} }
  for skill = 0, 28 do env.levels[skill] = 50 end
  local function bus(name)
    return { Subscribe = function(k, f) env.events[name .. ":" .. k] = f end,
      Unsubscribe = function(k) env.events[name .. ":" .. k] = nil end }
  end
  _G.Event = { ServerLogic = bus("Tick"), ChatMessage = bus("Chat"), ContentLayerReady = bus("Content"), SettingsLayerReady = bus("Settings") }
  _G.ui = { SelectionChangeEvent = { SELECTED = 1 } }
  _G.log = function() end
  _G.Player = { IsAvailable = function() return true end,
    GetEntity = function() return { displayName = "6ing" } end,
    GetLevelUncapped = function(skill) return env.levels[skill] end }
  _G.PersistentDB = memoryDb()
  if opts.settings then PersistentDB:SetStructuredData(Store.KEY, opts.settings) end
  _G.prettyui = { SimpleView = { new = function(parent)
    local list = parent.kind == "settings" and env.settings or env.panels
    local calls = {}; list[#list + 1] = calls
    return setmetatable({}, { __index = function(_, method)
      if method == "Destroy" then return function() end end
      return function(_, ...)
        local call = { method = method, args = { ... } }
        if method == "AddText" or method == "AddTitle" then call.content = type(call.args[1]) == "table" and call.args[1].text or call.args[1] end
        calls[#calls + 1] = call
        return call
      end
    end })
  end } }
  for key in pairs(package.loaded) do if key:match("^src/") then package.loaded[key] = nil end end
  if opts.camera then
    require("src/game/capture").setProvider(function(fileName, folder, onDone)
      env.shots[#env.shots + 1] = { file = fileName, folder = folder }
      onDone(true, (folder ~= "" and folder or "Screenshots") .. "\\" .. fileName)
    end)
  end
  dofile("main.lua")
  env.events["Content:auto-screenshot:content"]({ component = { kind = "content" } })
  env.events["Tick:auto-screenshot:watch"]() -- login baseline
  return env
end

local function tick(env) env.events["Tick:auto-screenshot:watch"]() end
local function chat(env, text) env.events["Chat:auto-screenshot:watch"]({ chatMessage = text }) end
local function panelText(env)
  local out = {}
  for _, c in ipairs(env.panels[#env.panels]) do if c.content then out[#out + 1] = c.content end end
  return table.concat(out, "\n")
end
local function idle(env, ticks) for _ = 1, ticks do tick(env) end end

function T.without_camera_it_lists_what_it_would_capture()
  local env = boot()
  env.levels[10] = 98; tick(env); idle(env, 6)
  env.levels[10] = 99; tick(env)
  local text = panelText(env)
  A.truthy(text:find("aren't available to plugins yet", 1, true))
  A.truthy(text:find("Level 99 Fishing  (not captured)", 1, true))
  PluginShutdown()
end

function T.default_mode_captures_99s_and_120s_only()
  local env = boot({ camera = true })
  env.levels[10] = 51; tick(env); idle(env, 6)
  A.eq(#env.shots, 0, "51 is not a 99")
  env.levels[10] = 99; tick(env); idle(env, 6)
  env.levels[5] = 120; tick(env)
  A.eq(#env.shots, 2)
  A.eq(env.shots[1].file, "6ing_Level-99-Fishing_0001.png"); A.eq(env.shots[2].file, "6ing_Level-120-Prayer_0002.png")
  PluginShutdown()
end

function T.all_levels_mode()
  local env = boot({ camera = true, settings = { levelMode = "all" } })
  env.levels[0] = 51; tick(env); idle(env, 6)
  env.levels[0] = 52; tick(env)
  A.eq(#env.shots, 2)
  PluginShutdown()
end

function T.only_broadcasts_mode_ignores_level_ups()
  local env = boot({ camera = true, settings = { levelMode = "broadcasts" } })
  env.levels[10] = 99; tick(env); idle(env, 6)
  A.eq(#env.shots, 0)
  chat(env, "News: 6ing has achieved level 99 in Fishing!")
  A.eq(#env.shots, 1, "the broadcast itself is captured")
  PluginShutdown()
end

function T.a_99_and_its_broadcast_make_one_screenshot()
  local env = boot({ camera = true })
  env.levels[10] = 99; tick(env)
  chat(env, "News: 6ing has achieved level 99 in Fishing!")
  tick(env)
  A.eq(#env.shots, 1)
  PluginShutdown()
end

function T.other_players_broadcasts_are_ignored()
  local env = boot({ camera = true })
  chat(env, "News: Zezima received a drop: Dragon rider lance")
  A.eq(#env.shots, 0)
  PluginShutdown()
end

function T.rare_drops_and_toggles()
  local env = boot({ camera = true })
  chat(env, "A golden beam shines over one of your items.")
  A.eq(#env.shots, 1); A.eq(env.shots[1].file, "6ing_Rare-drop_0001.png")
  env.events["Settings:auto-screenshot:settings"]({ component = { kind = "settings" } })
  for _, c in ipairs(env.settings[1]) do
    if c.method == "AddCheckboxButton" then
      c.args[2].onChange(nil, nil, "rareDrops", false)
      c.args[2].onChange(nil, nil, "broadcasts", false)
    end
  end
  idle(env, 6)
  chat(env, "A golden beam shines over one of your items.")
  chat(env, "News: 6ing received a drop: Dragon rider lance")
  A.eq(#env.shots, 1, "both switched off")
  A.eq(Store.new(PersistentDB):get("rareDrops"), false, "off stays off")
  PluginShutdown()
end

function T.custom_folder_is_used()
  local env = boot({ camera = true })
  env.events["Settings:auto-screenshot:settings"]({ component = { kind = "settings" } })
  for _, c in ipairs(env.settings[1]) do
    if c.method == "AddTextField" then c.args[1].onChange(nil, nil, "D:\\RS3 shots") end
  end
  chat(env, "News: 6ing received a drop: Dragon rider lance")
  A.eq(env.shots[1].folder, "D:\\RS3 shots")
  A.truthy(panelText(env):find("saved D:\\RS3 shots\\6ing_Broadcast_0001.png", 1, true))
  PluginShutdown()
end

function T.counter_continues_after_restart()
  local env = boot({ camera = true })
  chat(env, "News: 6ing received a drop: Dragon rider lance")
  local db = PersistentDB
  PluginShutdown()
  local saved = db:GetStructuredData(Store.KEY)
  A.eq(saved.counter, 1)
  local env2 = boot({ camera = true, settings = saved })
  chat(env2, "News: 6ing received a drop: Abyssal whip")
  A.eq(env2.shots[1].file, "6ing_Broadcast_0002.png")
  PluginShutdown()
end

function T.settings_offer_the_five_level_options()
  local env = boot()
  env.events["Settings:auto-screenshot:settings"]({ component = { kind = "settings" } })
  local combo
  for _, c in ipairs(env.settings[1]) do if c.method == "AddComboBox" then combo = c end end
  local labels = {}
  for i, e in ipairs(combo.args[1].entries) do labels[i] = e.label end
  A.list(labels, { "All levels", "Only 99s", "Only 120s", "99s & 120s", "Only broadcasts" })
  A.eq(combo.args[1].selectedID, "99_120", "99s & 120s by default")
  combo.args[1].onChange(nil, "120", "Only 120s", 1)
  A.eq(Store.new(PersistentDB):get("levelMode"), "120")
  PluginShutdown()
end

function T.camera_failure_is_reported_not_crashing()
  local env = boot()
  require("src/game/capture").setProvider(function() error("disk full") end)
  chat(env, "News: 6ing received a drop: Dragon rider lance")
  A.truthy(panelText(env):find("not captured", 1, true))
  PluginShutdown()
end

function T.shutdown_unsubscribes()
  local env = boot()
  PluginShutdown(); PluginShutdown()
  A.eq(next(env.events), nil)
end

function T.achievements_are_captured_and_can_be_turned_off()
  local env = boot({ camera = true })
  chat(env, "Congratulations! You have completed the achievement: Into the Abyss!")
  A.eq(#env.shots, 1); A.eq(env.shots[1].file, "6ing_Achievement-Into-the-Abyss_0001.png")
  A.truthy(panelText(env):find("Achievement Into the Abyss", 1, true))
  env.events["Settings:auto-screenshot:settings"]({ component = { kind = "settings" } })
  for _, c in ipairs(env.settings[1]) do
    if c.method == "AddCheckboxButton" then c.args[2].onChange(nil, nil, "achievements", false) end
  end
  idle(env, 6)
  chat(env, "Congratulations! You have completed the achievement: Sink or Swim!")
  A.eq(#env.shots, 1, "off")
  A.eq(Store.new(PersistentDB):get("achievements"), false)
  PluginShutdown()
end

function T.achievement_and_its_broadcast_make_one_screenshot()
  local env = boot({ camera = true })
  chat(env, "Congratulations! You have completed the achievement: Insane Final Boss!")
  chat(env, "News: 6ing has completed the achievement: Insane Final Boss")
  A.eq(#env.shots, 1)
  PluginShutdown()
end

return T
