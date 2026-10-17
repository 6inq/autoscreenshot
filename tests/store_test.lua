local A = require("assert")
local Store = require("src/core/store")

local T = {}

local function memoryDb()
  local db = { data = {} }
  function db:GetStructuredData(key) return self.data[key] end
  function db:SetStructuredData(key, value) self.data[key] = value end
  return db
end

function T.defaults()
  local s = Store.new(memoryDb())
  A.eq(s:get("levelMode"), "99_120"); A.eq(s:get("broadcasts"), true); A.eq(s:get("rareDrops"), true)
  A.eq(s:get("folder"), ""); A.eq(s:get("counter"), 0)
end

function T.validates_and_persists()
  local db = memoryDb()
  local s = Store.new(db)
  A.eq(s:set("levelMode", "all"), true); A.eq(s:set("levelMode", "150"), false)
  A.eq(s:set("folder", string.rep("x", 300)), false); A.eq(s:set("folder", "C:\\Shots"), true)
  s:set("broadcasts", false)
  local r = Store.new(db)
  A.eq(r:get("levelMode"), "all"); A.eq(r:get("folder"), "C:\\Shots"); A.eq(r:get("broadcasts"), false)
end

function T.counter_increments_and_persists()
  local db = memoryDb()
  local s = Store.new(db)
  A.eq(s:nextCounter(), 1); A.eq(s:nextCounter(), 2)
  A.eq(Store.new(db):get("counter"), 2)
end

function T.invalid_stored_values_fall_back()
  local db = memoryDb()
  db.data[Store.KEY] = { levelMode = "x", broadcasts = "y", counter = -4, folder = 9 }
  local s = Store.new(db)
  A.eq(s:get("levelMode"), "99_120"); A.eq(s:get("broadcasts"), true); A.eq(s:get("counter"), 0); A.eq(s:get("folder"), "")
end

return T
