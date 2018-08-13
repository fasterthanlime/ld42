local buildings = {
  infra = {
    {
      name = "wires",
      cost = 800
    },
    {
      name = "plastic",
      cost = 800
    },
    {
      name = "jewelry",
      cost = 800
    },
    {
      name = "toys",
      cost = 800
    },
    {
      name = "microchips",
      cost = 800
    }
  },
  mine = {
    {
      name = "oil",
      cost = 800
    },
    {
      name = "copper",
      cost = 800
    },
    {
      name = "gold",
      cost = 800
    },
    {
      name = "diamond",
      cost = 800
    }
  },
  misc = {
    {
      name = "cross",
      cost = 0
    },
    {
      name = "bg",
      cost = 0
    }
  },
  terrain = {
    {
      name = "city",
      cost = 0
    },
    {
      name = "mountains",
      cost = 0,
      terrain = true
    }
  }
}
local buildings_by_name = { }
for cat, items in pairs(buildings) do
  for _index_0 = 1, #items do
    local i = items[_index_0]
    buildings_by_name[i.name] = i
  end
end
buildings.find = function(name)
  do
    local b = buildings_by_name[name]
    if b then
      return b
    else
      return error("building not found: " .. tostring(name))
    end
  end
end
return buildings
