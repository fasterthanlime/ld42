local buildings = {
  infra = {
    {
      name = "wires",
      cost = 800,
      inputs = {
        {
          name = "copper",
          amount = 1
        }
      },
      output = {
        name = "wires",
        amount = 10
      }
    },
    {
      name = "plastic",
      cost = 800,
      output = {
        name = "plastic"
      },
      inputs = {
        {
          name = "oil",
          amount = 1
        }
      },
      output = {
        name = "plastic",
        amount = 4
      }
    },
    {
      name = "jewelry",
      cost = 800,
      inputs = {
        {
          name = "diamonds",
          amount = 1
        },
        {
          name = "gold",
          amount = 2
        }
      },
      output = {
        name = "jewelry",
        amount = 4
      }
    },
    {
      name = "toys",
      cost = 800,
      inputs = {
        {
          name = "plastic",
          amount = 2
        }
      },
      output = {
        name = "toys",
        amount = 10
      }
    },
    {
      name = "microchips",
      cost = 800,
      inputs = {
        {
          name = "diamonds",
          amount = 5
        }
      },
      output = {
        name = "microchips",
        amount = 1
      }
    }
  },
  mine = {
    {
      name = "oil",
      cost = 800,
      inputs = { },
      output = {
        name = "oil",
        amount = 4
      }
    },
    {
      name = "copper",
      cost = 800,
      inputs = { },
      output = {
        name = "copper",
        amount = 4
      }
    },
    {
      name = "gold",
      cost = 800,
      inputs = { },
      output = {
        name = "gold",
        amount = 4
      }
    },
    {
      name = "diamond",
      cost = 800,
      inputs = { },
      output = {
        name = "diamonds",
        amount = 4
      }
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
