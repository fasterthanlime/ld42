local buildings = {
  infra = {
    {
      name = "wires",
      price = 800
    },
    {
      name = "plastic",
      price = 800
    },
    {
      name = "jewelry",
      price = 800
    },
    {
      name = "toys",
      price = 800
    },
    {
      name = "microchips",
      price = 800
    }
  },
  mine = {
    {
      name = "oil",
      price = 800
    },
    {
      name = "copper",
      price = 800
    },
    {
      name = "gold",
      price = 800
    },
    {
      name = "diamond",
      price = 800
    }
  },
  misc = {
    {
      name = "cross",
      price = 0
    },
    {
      name = "bg",
      price = 0
    }
  },
  terrain = {
    {
      name = "city",
      price = 0
    },
    {
      name = "mountains",
      price = 0,
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
