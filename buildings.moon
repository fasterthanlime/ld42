
buildings = {
  infra: {
    {
      name: "wires"
      cost: 800
    }
    {
      name: "plastic"
      cost: 800
    }
    {
      name: "jewelry"
      cost: 800
    }
    {
      name: "toys"
      cost: 800
    }
    {
      name: "microchips"
      cost: 800
    }
  }

  mine: {
    {
      name: "oil"
      cost: 800
    }
    {
      name: "copper"
      cost: 800
    }
    {
      name: "gold"
      cost: 800
    }
    {
      name: "diamond"
      cost: 800
    }
  }

  misc: {
    {
      name: "cross"
      cost: 0
    }
    {
      name: "bg"
      cost: 0
    }
  }

  terrain: {
    {
      name: "city"
      cost: 0
    }
    {
      name: "mountains"
      cost: 0
      terrain: true
    }
  }
}

buildings_by_name = {}
for cat, items in pairs buildings
  for i in *items
    buildings_by_name[i.name] = i

buildings.find = (name) ->
  if b = buildings_by_name[name]
    b
  else
    error "building not found: #{name}"

buildings
