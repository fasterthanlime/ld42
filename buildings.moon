
buildings = {
  infra: {
    {
      name: "wires"
      cost: 800
      input: {
        {name: "copper", amount: 1}
      }
      output: {name: "wires", amount: 10}
    }
    {
      name: "plastic"
      cost: 800
      output: {name: "plastic"}
      input: {
        {name: "oil", amount: 1}
      }
      output: {name: "plastic", amount: 4}
    }
    {
      name: "jewelry"
      cost: 800
      input: {
        {name: "diamonds", amount: 1}
        {name: "gold", amount: 2}
      }
      output: {name: "jewelry", amount: 4}
    }
    {
      name: "toys"
      cost: 800
      input: {
        {name: "plastic", amount: 2}
      }
      output: {name: "toys", amount: 10}
    }
    {
      name: "microchips"
      cost: 800
      input: {
        {name: "diamonds", amount: 5}
      }
      output: {name: "microchips", amount: 1}
    }
  }

  mine: {
    {
      name: "oil"
      cost: 800
      input: {}
      output: {name: "oil", amount: 1}
    }
    {
      name: "copper"
      cost: 800
      input: {}
      output: {name: "copper", amount: 1}
    }
    {
      name: "gold"
      cost: 800
      input: {}
      output: {name: "gold", amount: 1}
    }
    {
      name: "diamond"
      cost: 800
      input: {}
      output: {name: "diamond", amount: 1}
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
