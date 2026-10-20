local Capture = {}

local provider = nil

function Capture.setProvider(fn)
  provider = fn
end

function Capture.available()
  return provider ~= nil
end

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
