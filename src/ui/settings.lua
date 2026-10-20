-- Settings panel: which levels, broadcasts, rare drops, and where to save.
local Triggers = require("src/core/triggers")
local Combo = require("src/ui/combo")

local Settings = {}

local EVENT_ID = "auto-screenshot:settings"
local view

local function mount(parent, store)
  Settings.destroy()
  view = prettyui.SimpleView.new(parent, { width = parent.width, height = parent.height })
  view:AddTitle("Auto Screenshot")

  view:AddText("Level-ups to capture")
  local choices = {}
  for index, mode in ipairs(Triggers.LEVEL_MODES) do choices[index] = { label = mode.label, key = mode.id } end
  view:AddComboBox(Combo.options(choices, store:get("levelMode"), function(key) store:set("levelMode", key) end))

  view:AddCheckboxButton({
    { text = "Your game broadcasts (rare drops, 99s, 120s, and more)", value = "broadcasts", selected = store:get("broadcasts") },
    { text = "Rare drop messages (loot beam, pets)", value = "rareDrops", selected = store:get("rareDrops") },
    { text = "Achievements completed", value = "achievements", selected = store:get("achievements") },
  }, { onChange = function(_, _, changed, selected) store:set(changed, selected) end })

  view:AddTitle("Save location")
  view:AddText({ text = "Folder for screenshots. Leave empty for the game's default screenshot folder.", height = 48 })
  view:AddTextField({
    placeholder = "e.g. C:\\Users\\you\\Pictures\\RS3", text = store:get("folder"),
    onChange = function(_, _, text) store:set("folder", text or "") end,
  })
end

function Settings.start(store)
  Event.SettingsLayerReady.Subscribe(EVENT_ID, function(event)
    local ok, err = pcall(mount, event.component, store)
    if not ok and log then log("[auto-screenshot] settings failed: " .. tostring(err)) end
  end)
end

function Settings.destroy()
  if view then pcall(function() return view:Destroy() end) end
  view = nil
end

function Settings.stop()
  pcall(function() return Event.SettingsLayerReady.Unsubscribe(EVENT_ID) end)
  Settings.destroy()
end

return Settings
