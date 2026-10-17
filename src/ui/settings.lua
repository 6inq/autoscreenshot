-- Settings panel: which levels, broadcasts, rare drops, and where to save.
local Triggers = require("src/core/triggers")

local Settings = {}

local EVENT_ID = "auto-screenshot:settings"
local view

local function mount(parent, store)
  Settings.destroy()
  view = prettyui.SimpleView.new(parent, { width = parent.width, height = parent.height })
  view:AddTitle("Auto Screenshot")

  view:AddText("Level-ups to capture")
  local entries = {}
  for index, mode in ipairs(Triggers.LEVEL_MODES) do entries[index] = { label = mode.label, id = mode.id } end
  view:AddComboBox({
    entries = entries, selectedID = store:get("levelMode"),
    onChange = function(_, entryID, _, eventType)
      if eventType ~= nil and eventType ~= ui.SelectionChangeEvent.SELECTED then return end
      store:set("levelMode", entryID)
    end,
  })

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
  if view then pcall(view.Destroy, view) end
  view = nil
end

function Settings.stop()
  pcall(Event.SettingsLayerReady.Unsubscribe, EVENT_ID)
  Settings.destroy()
end

return Settings
