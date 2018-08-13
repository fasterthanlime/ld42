
buildings = require "buildings"

builtins = {
  {i: 3, j: 4, building: buildings.find("terrain", "city")}

  ----

  {i: 5, j: 3, building: buildings.find("terrain", "mountains")}
  {i: 5, j: 4, building: buildings.find("terrain", "mountains")}
  {i: 5, j: 5, building: buildings.find("terrain", "mountains")}

  {i: 6, j: 3, building: buildings.find("terrain", "mountains")}
  {i: 6, j: 4, building: buildings.find("terrain", "mountains")}
  {i: 6, j: 5, building: buildings.find("terrain", "mountains")}

  {i: 7, j: 3, building: buildings.find("terrain", "mountains")}
  {i: 7, j: 4, building: buildings.find("terrain", "mountains")}

  ----

  {i: 9, j: 3, building: buildings.find("terrain", "mountains")}
  {i: 9, j: 4, building: buildings.find("terrain", "mountains")}

  {i: 10, j: 3, building: buildings.find("terrain", "mountains")}
  {i: 10, j: 4, building: buildings.find("terrain", "mountains")}

  {i: 11, j: 3, building: buildings.find("terrain", "mountains")}
  {i: 11, j: 4, building: buildings.find("terrain", "mountains")}

  {i: 12, j: 3, building: buildings.find("terrain", "mountains")}
  {i: 12, j: 4, building: buildings.find("terrain", "mountains")}
  {i: 12, j: 5, building: buildings.find("terrain", "mountains")}

  {i: 10, j: 2, building: buildings.find("mine", "diamond")}
  {i: 10, j: 7, building: buildings.find("mine", "gold")}
}