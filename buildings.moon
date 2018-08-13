
buildings = {
  infra: {
    {
      name: "wires"
      price: 800
    }
    {
      name: "plastic"
      price: 800
    }
    {
      name: "jewelry"
      price: 800
    }
    {
      name: "toys"
      price: 800
    }
    {
      name: "microchips"
      price: 800
    }
  }

  mine: {
    {
      name: "oil"
      price: 800
    }
    {
      name: "copper"
      price: 800
    }
    {
      name: "gold"
      price: 800
    }
    {
      name: "diamond"
      price: 800
    }
  }

  misc: {
    {
      name: "cross"
      price: 0
    }
    {
      name: "bg"
      price: 0
    }
  }

  terrain: {
    {
      name: "city"
      price: 0
    }
    {
      name: "mountains"
      price: 0
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
