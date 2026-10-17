-- The single place Auto Screenshot takes and saves a picture.
--
-- Jagex has not published a screenshot or file API for plugins (none of the live plugins
-- can do either). When it exists, set a provider here; nothing else changes. Until then the
-- plugin still detects every moment and lists it in the panel as "not captured".
local Capture = {}

local provider = nil

-- provider(fileName, folder, onDone) where onDone(ok, savedPathOrError).
-- folder is "" for the client's default screenshot location.
function Capture.setProvider(fn)
  provider = fn
end

function Capture.available()
  return provider ~= nil
end

---@param onDone fun(ok: boolean, detail: string)
function Capture.take(fileName, folder, onDone)
  if not provider then
    onDone(false, "Screenshots not available yet")
    return
  end
  local ok, err = pcall(provider, fileName, folder or "", function(success, detail)
    onDone(success == true, tostring(detail or ""))
  end)
  if not ok then onDone(false, tostring(err)) end
end

return Capture
