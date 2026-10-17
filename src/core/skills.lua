-- RS3 skill ids (0..28, the client's stat order) and their names.
local Skills = {}

Skills.FIRST, Skills.LAST = 0, 28

Skills.NAMES = {
  [0] = "Attack", "Defence", "Strength", "Constitution", "Ranged", "Prayer", "Magic", "Cooking",
  "Woodcutting", "Fletching", "Fishing", "Firemaking", "Crafting", "Smithing", "Mining", "Herblore",
  "Agility", "Thieving", "Slayer", "Farming", "Runecrafting", "Hunter", "Construction", "Summoning",
  "Dungeoneering", "Divination", "Invention", "Archaeology", "Necromancy",
}

-- RS3 names from the list (the client enum says HITPOINTS, players say Constitution);
-- the client's SkillType enum only covers skills added after this list.
function Skills.name(id, skillType)
  if Skills.NAMES[id] then return Skills.NAMES[id] end
  if type(skillType) == "table" then
    for name, value in pairs(skillType) do
      if value == id and type(name) == "string" then
        return (name:sub(1, 1) .. name:sub(2):lower():gsub("_", " "))
      end
    end
  end
  return Skills.NAMES[id] or ("Skill " .. tostring(id))
end

return Skills
