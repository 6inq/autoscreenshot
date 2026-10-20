local Skills = {}

Skills.FIRST, Skills.LAST = 0, 28

Skills.NAMES = {
  [0] = "Attack", "Defence", "Strength", "Constitution", "Ranged", "Prayer", "Magic", "Cooking",
  "Woodcutting", "Fletching", "Fishing", "Firemaking", "Crafting", "Smithing", "Mining", "Herblore",
  "Agility", "Thieving", "Slayer", "Farming", "Runecrafting", "Hunter", "Construction", "Summoning",
  "Dungeoneering", "Divination", "Invention", "Archaeology", "Necromancy",
}

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
