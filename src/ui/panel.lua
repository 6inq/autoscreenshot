-- Ribbon panel: status and the most recent moments (captured or not).
local Capture = require("src/game/capture")

local Panel = {}

local EVENT_ID = "auto-screenshot:content"
local LISTENER = "panel"
local parent, view

Panel.WAITING = "Screenshots aren't available to plugins yet. Moments below are what would have been captured."

local function build(app)
  view:AddTitle("Auto Screenshot")
  view:AddText("by 6ing")
  view:AddText({ text = Capture.available() and "Ready." or Panel.WAITING, height = 48 })
  view:AddTitle("Recent moments")
  if #app.history == 0 then view:AddText("Nothing yet. Level up or get a broadcast!") end
  for _, entry in ipairs(app.history) do
    local status = entry.captured and ("saved " .. entry.detail) or "not captured"
    view:AddText({ text = entry.text .. "  (" .. status .. ")", height = 24 })
  end
end

local function render(app)
  if not parent then return end
  if view then pcall(view.Destroy, view) end
  view = prettyui.SimpleView.new(parent, { width = parent.width, height = parent.height })
  local ok, err = pcall(build, app)
  if not ok and log then log("[auto-screenshot] panel failed: " .. tostring(err)) end
end

function Panel.start(app)
  Event.ContentLayerReady.Subscribe(EVENT_ID, function(event)
    parent = event.component
    app:onChange(LISTENER, function() render(app) end)
  end)
end

function Panel.stop(app)
  pcall(Event.ContentLayerReady.Unsubscribe, EVENT_ID)
  if app then app:onChange(LISTENER, nil) end
  if view then pcall(view.Destroy, view) end
  view, parent = nil, nil
end

return Panel
