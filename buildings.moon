
buildings = {
  infra: {
    {
      name: "wires"
      cost: 550
      inputs: {
        {name: "copper", amount: 1}
      }
      output: {name: "wires", amount: 10}
    }
    {
      name: "plastic"
      cost: 1200
      inputs: {
        {name: "oil", amount: 1}
      }
      output: {name: "plastic", amount: 4}
    }
    {
      name: "jewelry"
      cost: 10000
      inputs: {
        {name: "diamonds", amount: 1}
        {name: "gold", amount: 2}
      }
      output: {name: "jewelry", amount: 4}
    }
    {
      name: "toys"
      cost: 2500
      inputs: {
        {name: "plastic", amount: 2}
      }
      output: {name: "toys", amount: 10}
    }
    {
      name: "microchips"
      cost: 800
      inputs: {
        {name: "diamonds", amount: 5}
      }
      output: {name: "microchips", amount: 1}
    }
  }

  mine: {
    {
      name: "oil"
      cost: 800
      inputs: {}
      output: {name: "oil", amount: 2}
    }
    {
      name: "copper"
      cost: 800
      inputs: {}
      output: {name: "copper", amount: 2}
    }
    {
      name: "gold"
      cost: 800
      inputs: {}
      output: {name: "gold", amount: 2}
    }
    {
      name: "diamond"
      cost: 800
      inputs: {}
      output: {name: "diamonds", amount: 2}
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
