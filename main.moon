lick = require "lick"
lick.reset = true -- reload game every time it's compiled

import CheckCollision, log from require "utils"
import graphics, mouse, keyboard, math from love

local buildUI
local newImage
local buildRoads

numCols = 14
numRows = 10
slotSide = 60

unitSide = 30

mapUnits = {}

initialMapX = 0
initialMapY = 60

screenWidth = 1200
screenHeight = 700

initialPaletteX = 10
paletteItemsPerRow = 4
paletteItemSide = 40
paletteItemSpacing = 15
paletteTotalWidth = initialPaletteX + (paletteItemSide+paletteItemSpacing) * paletteItemsPerRow + 30

text = ""
startedAt = nil
font = nil
paused = true
roundTicks = 0
stepIndex = 0
buildingTab = "infra"
hasHover = false

money = 2000

pressed = false
hovered = nil

roadCost = 20
destructionCost = 10

map = {}

uiObjects = {}

cursors = {
  "pointer"
  "hand"
  "tri-bottomleft"
  "tri-bottomright"
}
currentCursor = "pointer"
currentBuilding = nil
currentUnit = nil
currentTool = "road"

buttons = {
  "play"
  "pause"
  "slot"
}
buttonExtras = {
  "toolbar"
  "bg"
}

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

units = {
  {
    name: "jeep"
    price: 1000
  }
  {
    name: "van"
    price: 2500
  }
  {
    name: "truck"
    price: 8000
  }
}

findBuilding = (cat, name) ->
  for b in *buildings[cat]
    if b.name == name
      return b
  nil

misc = {
  "arrow"
}

roads = {
  "road"
  "road-down"
  "road-left"
  "road-left-down"
  "road-left-right"
  "road-left-right-down"
  "road-left-right-up"
  "road-left-right-up-down"
  "road-left-up"
  "road-left-up-down"
  "road-right"
  "road-right-down"
  "road-right-up"
  "road-right-up-down"
  "road-up"
  "road-up-down"
}

dir = {
  l: {-1, 0},
  r: {1, 0},
  u: {0, -1},
  d: {0, 1},
}

PI = 3.14159265 -- that's all I can remember tonight

dir_to_vec = (d) ->
  switch d
    when dir.l then {-1, 0}
    when dir.r then {1, 0}
    when dir.u then {0, -1}
    when dir.d then {0, 1}
    else {0, 0}

-- assuming the sprite points up
dir_to_angle = (d) ->
  switch d
    when dir.l then -PI/2
    when dir.r then PI/2
    when dir.d then PI
    when dir.u then 0
    else 0

vec_to_dir = (x, y) ->
  switch true
    when x == -1 and y == 0 then dir.l
    when x == 1 and y == 0 then dir.r
    when x == 0 and y == -1 then dir.u
    when x == 0 and y == 1 then dir.d
    else nil

dir_opposite = (d) ->
  switch d
    when dir.l then dir.r
    when dir.r then dir.l
    when dir.u then dir.d
    when dir.d then dir.u
    else 0

random_dir = ->
  x = math.random!
  switch true
    when x < 0.25
      dir.l
    when x < 0.5
      dir.r
    when x < 0.75
      dir.u
    else
      dir.d

dirs_to_road = (dirs) ->
  name = "road"
  if dirs[dir.l]
    name = "#{name}-left"
  if dirs[dir.r]
    name = "#{name}-right"
  if dirs[dir.u]
    name = "#{name}-up"
  if dirs[dir.d]
    name = "#{name}-down"
  return name

object_world_pos = (i, j) ->
  x = initialMapX + i * slotSide
  y = initialMapY + (j-1) * slotSide
  return x, y

images = {}

uiObjectTouchesMouse = (obj) ->
  x, y = mouse.getPosition!
  CheckCollision(x-2, y-2, 4, 4, obj.x, obj.y, obj.w, obj.h)

step = ->
  stepIndex += 1

  log "stepping!"
  for u in *mapUnits
    d = random_dir!
    {diffI, diffJ} = dir_to_vec d
    log "diffI = #{diffI}, diffJ = #{diffJ}!"
    u.i += diffI
    u.j += diffJ
    io.flush!

isShiftDown = ->
  keyboard.isDown("lshift") or keyboard.isDown("rshift")

updateRoadBuilding = (oldHover, newHover) ->
  return unless currentTool == "road"
  return unless pressed
  return unless oldHover and newHover
  return if oldHover == newHover

  diffI = newHover.i - oldHover.i
  diffJ = newHover.j - oldHover.j
  d = vec_to_dir diffI, diffJ
  return unless d

  {x, y} = dir_to_vec(d)
  oldIdx = oldHover.i + (oldHover.j-1) * numCols
  newIdx = newHover.i + (newHover.j-1) * numCols

  oldC = map[oldIdx]
  newC = map[newIdx]

  return if newC.building and newC.building.terrain
  return if oldC.building and oldC.building.terrain

  didCost = false

  if isShiftDown!
    -- delete roads
    if map[oldIdx] and map[oldIdx].dirs and map[oldIdx].dirs[d]
      didCost = true
      map[oldIdx].dirs[d] = nil
    if map[newIdx] and map[newIdx].dirs and map[newIdx].dirs[dir_opposite(d)]
      didCost = true
      map[newIdx].dirs[dir_opposite(d)] = nil

    if didCost
      money -= destructionCost
  else
    -- add roads
    map[oldIdx] or= {}
    map[oldIdx].road = true
    map[oldIdx].dirs or= {}
    unless map[oldIdx].dirs[d]
      didCost = true
    map[oldIdx].dirs[d] = true

    map[newIdx] or= {}
    map[newIdx].road = true
    map[newIdx].dirs or= {}
    unless map[newIdx].dirs[dir_opposite(d)]
      didCost = true
    map[newIdx].dirs[dir_opposite(d)] = true

    if didCost
      money -= roadCost
  
  buildRoads!

updateUI = ->
  lastHovered = hovered
  hovered = nil
  for obj in *uiObjects
    if obj.hover = uiObjectTouchesMouse(obj)
      hovered = obj
  if hovered
    currentCursor = "hand"
  else
    currentCursor = "pointer"

  updateRoadBuilding lastHovered, hovered
  text = "started #{startedAt.hour}:#{startedAt.min}:#{startedAt.sec} | step #{stepIndex} | money $#{money}"

updateSim = (dt) ->
  roundTicks += dt
  if roundTicks > 1
    roundTicks -= 1
    step()

love.update = (dt) ->
  unless paused
    updateSim dt
  updateUI!

love.mousepressed = (x, y, button, istouch, presses) ->
  pressed = true 

  for obj in *uiObjects
    if uiObjectTouchesMouse(obj) and obj.onclick
      obj.onclick!
      return

love.mousereleased = (x, y, button, istouch, presses) ->
  pressed = false

local standardButtons

buildRoads = ->
  for i=1,numCols
    for j=1,numRows
      if c = map[i+(j-1)*numCols]
        if c.road and c.dirs
          c.road = dirs_to_road c.dirs
  buildUI!

buildUI = ->
  uiObjects = {}

  if paused
    table.insert uiObjects, standardButtons.play
  else
    table.insert uiObjects, standardButtons.pause

  do
    obj = {
      loc: "palette"
      icon: images.roads["road-left-right"]
      onclick: (->
        currentTool = "road"
      )
    }
    table.insert uiObjects, obj

  for b in *(buildings[buildingTab])
    obj = {
      loc: "palette"
      icon: images.buildings[b.name]
      onclick: (->
        currentTool = "building"
        currentBuilding = b
      )
    }
    unless obj.icon 
      error("could not find icon for building #{b}")
    table.insert uiObjects, obj

  for u in *units
    obj = {
      loc: "palette"
      icon: images.units[u.name]
      onclick: (->
        currentTool = "unit"
        currentUnit = u
      )
    }
    table.insert uiObjects, obj

  for i=1,numCols
    for j=1,numRows
      table.insert uiObjects, {
        :i, :j
        loc: "map"
        meta: true
        icon: images.buttons.slot
        onclick: (->
          switch currentTool
            when "road"
              nil -- muffin
            when "unit"
              if currentUnit
                table.insert mapUnits, {
                  :i, :j
                  unit: currentUnit
                }
            when "building"
              idx = i+(j-1)*numCols
              if map[idx] and map[idx].protected
                return
              if isShiftDown!
                map[idx].building = nil
                buildUI!
              else
                map[idx] or= {}
                map[idx].building = currentBuilding
                buildUI!
        )
      }

  for i=1,numCols
    for j=1,numRows
      if c = map[i+(j-1)*numCols]
        obj = {
          :i, :j
          loc: "map"
          building: c.building
          protected: c.protected
        }
        if c.road
          obj.roadIcon = images.roads[c.road]
        if c.building
          obj.icon = images.buildings[c.building.name]

        table.insert uiObjects, obj

  -- now do layout
  do
    toolbarX = 10
    toolbarY = 10
        
    paletteBaseX = screenWidth - paletteTotalWidth
    paletteX = initialPaletteX
    paletteY = 100
    paletteN = 0

    for i, obj in ipairs uiObjects
      unless obj
        error("uiObject #{i} is nil")

      obj.hover = false

      switch obj.loc
        when "toolbar"
          obj.x = toolbarX
          obj.y = toolbarY
          obj.w = 40
          obj.h = 40
          toolbarX += 50
        when "palette"
          obj.x = paletteX + paletteBaseX
          obj.y = paletteY
          obj.w = paletteItemSide
          obj.h = paletteItemSide

          paletteN += 1
          paletteX += paletteItemSide + paletteItemSpacing
          if paletteN >= paletteItemsPerRow
            paletteN = 0
            paletteX = initialPaletteX
            paletteY += paletteItemSide + paletteItemSpacing
        when "map"
          obj.x, obj.y = object_world_pos obj.i, obj.j
          obj.w, obj.h = slotSide, slotSide
        else
          error "unknown location #{obj.loc}"

love.load = ->
  -- works around stdout not flushing on windows
  io.stdout\setvbuf "no"

  -- we have our own pointer
  mouse.setVisible false

  startedAt = os.date '*t' 
  font = graphics.newFont "fonts/BeggarsExtended.ttf", 28

  images.cursors = {}
  for k in *cursors
    images.cursors[k] = newImage "art/cursors/#{k}.png"

  images.buttons = {}
  for k in *buttons
    images.buttons[k] = newImage "art/buttons/#{k}.png"

  images.buttonExtras = {}
  for k in *buttonExtras
    images.buttonExtras[k] = newImage "art/buttons/#{k}.png"

  images.buildings = {}
  for cat, catBuildings in pairs buildings
    for spec in *catBuildings
      k = spec.name
      images.buildings[k] = newImage "art/buildings/#{k}.png"

  images.units = {}
  for spec in *units
    k = spec.name
    images.units[k] = newImage "art/units/#{k}.png"

  images.roads = {}
  for k in *roads
    images.roads[k] = newImage "art/roads/#{k}.png"

  images.misc = {}
  for k in *misc
    images.misc[k] = newImage "art/misc/#{k}.png"

  standardButtons = {
    pause: {
      loc: "toolbar"
      icon: images.buttons.pause
      onclick: (->
        paused = true
        buildUI!
      )
    }
    play: {
      loc: "toolbar"
      icon: images.buttons.play
      onclick: (->
        paused = false
        buildUI!
      )
    }
  }

  for i=1,numCols*numRows
    map[i] = {}

  builtins = {
    {i: 3, j: 4, building: findBuilding("terrain", "city")}

    ----

    {i: 5, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 5, j: 4, building: findBuilding("terrain", "mountains")}
    {i: 5, j: 5, building: findBuilding("terrain", "mountains")}

    {i: 6, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 6, j: 4, building: findBuilding("terrain", "mountains")}
    {i: 6, j: 5, building: findBuilding("terrain", "mountains")}

    {i: 7, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 7, j: 4, building: findBuilding("terrain", "mountains")}

    ----

    {i: 9, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 9, j: 4, building: findBuilding("terrain", "mountains")}

    {i: 10, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 10, j: 4, building: findBuilding("terrain", "mountains")}

    {i: 11, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 11, j: 4, building: findBuilding("terrain", "mountains")}

    {i: 12, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 12, j: 4, building: findBuilding("terrain", "mountains")}
    {i: 12, j: 5, building: findBuilding("terrain", "mountains")}

    {i: 10, j: 2, building: findBuilding("mine", "diamond")}
    {i: 10, j: 7, building: findBuilding("mine", "gold")}
  }

  for b in *builtins
    {:i, :j, :building} = b
    idx = i+(j-1)*numCols
    c = {
      :i, :j
      :building
      protected: true
    }
    log "built-in #{building.name} at #{i}, #{j}"
    map[idx] = c
  buildRoads!

  buildUI!

drawFG = ->
  nil -- muffin

drawUI = ->
  graphics.reset!
  graphics.setColor 1, 1, 1
  -- graphics.setFont font
  graphics.print text, 20, screenHeight-30

  do 
    for obj in *uiObjects
      graphics.reset!
      if obj.hover and not obj.protected and obj.loc != "map"
        graphics.setColor 0.8, 0.8, 1.0
      else
        graphics.setColor 1, 1, 1
      {:x, :y} = obj

      scale = 1
      angle = 0

      switch obj.loc 
        when "palette"
          scale = 0.75
          angle = obj.hover and 0 or 3.14 * 1/64

      switch obj.loc 
        when "toolbar"
          graphics.draw images.buttonExtras.bg, x, y, angle, scale, scale
      if icon = obj.icon
        -- if obj.loc == "map" and not obj.meta
        --   graphics.draw images.buildings.bg, x, y, angle, scale, scale
        graphics.draw icon, x, y, angle, scale, scale
      else if icon = obj.roadIcon
        graphics.draw icon, x, y, angle, scale, scale

drawUnits = ->
  graphics.reset!

  for u in *mapUnits
    {:i, :j} = u
    x, y = object_world_pos i, j
    unitHalf = unitSide/2
    ox, oy = unitHalf, unitHalf

    slotHalf = slotSide/2
    x += slotHalf
    y += slotHalf
    angle = 0
    scale = 1
    img = images.units[u.unit.name]
    graphics.draw img, x, y, angle, scale, scale, ox, oy

drawMouse = ->
  x, y = mouse.getPosition!
  graphics.reset!
  img = images.cursors[currentCursor]
  graphics.draw img, x, y

  do
    img = nil
    switch currentTool
      when "building"
        if currentBuilding
          img = images.buildings[currentBuilding.name]
      when "unit"
        if currentUnit
          img = images.units[currentUnit.name]
      when "road"
        img = images.roads["road-left-right"]

    if img
      scale = 0.5
      x += 16
      y += 16
      if isShiftDown!
        graphics.setColor 1.0, 0.6, 0.6, 1
      else
        graphics.setColor 0.6, 1.0, 0.6, 1
      graphics.draw img, x, y, 0, scale, scale

love.draw = ->
  drawFG!
  drawUI!
  drawUnits!
  drawMouse!

newImage = (path) ->
  img = graphics.newImage path
  unless img
    error("image not found: #{img}")
  log "loaded #{path}"
  img
