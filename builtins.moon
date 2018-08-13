
buildings = require "buildings"

builtins = {
  {i: 3, j: 4, building: buildings.find("city")}

  ----

  {i: 5, j: 3, building: buildings.find("mountains")}
  {i: 5, j: 4, building: buildings.find("mountains")}
  {i: 5, j: 5, building: buildings.find("mountains")}

  {i: 6, j: 3, building: buildings.find("mountains")}
  {i: 6, j: 4, building: buildings.find("mountains")}
  {i: 6, j: 5, building: buildings.find("mountains")}

  {i: 7, j: 3, building: buildings.find("mountains")}
  {i: 7, j: 4, building: buildings.find("mountains")}

  ----

  {i: 9, j: 3, building: buildings.find("mountains")}
  {i: 9, j: 4, building: buildings.find("mountains")}

  {i: 10, j: 3, building: buildings.find("mountains")}
  {i: 10, j: 4, building: buildings.find("mountains")}

  {i: 11, j: 3, building: buildings.find("mountains")}
  {i: 11, j: 4, building: buildings.find("mountains")}

  {i: 12, j: 3, building: buildings.find("mountains")}
  {i: 12, j: 4, building: buildings.find("mountains")}
  {i: 12, j: 5, building: buildings.find("mountains")}

  {i: 10, j: 2, building: buildings.find("diamond")}
  {i: 5, j: 7, building: buildings.find("gold")}
}

builtins
