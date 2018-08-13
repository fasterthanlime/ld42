lick = require "lick"
lick.reset = true -- reload game every time it's compiled

import CheckCollision from require "utils"
import graphics, mouse, keyboard from love

local buildUI
local newImage
local buildRoads

numCols = 14
numRows = 10
slotSide = 60

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

money = 1000

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
    -- {
    --   name: "city"
    --   price: 4000
    -- }
    -- {
    --   name: "power-plant"
    --   price: 2000
    -- }
    -- {
    --   name: "cinema"
    --   price: 1400
    -- }
    -- {
    --   name: "library"
    --   price: 800
    -- }
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
}

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
  
  if (not currentBuilding) and pressed and lastHovered and hovered and lastHovered != hovered
    diffI = hovered.i - lastHovered.i
    diffJ = hovered.j - lastHovered.j
    if d = vec_to_dir diffI, diffJ
      {x, y} = dir_to_vec(d)
      text = "dragged in dir #{x}, #{y}"

      lastIdx = lastHovered.i + (lastHovered.j-1) * numCols
      idx = hovered.i + (hovered.j-1) * numCols

      didCost = false

      if keyboard.isDown("lshift") or keyboard.isDown("rshift")
        if map[lastIdx] and map[lastIdx].dirs
          didCost = true
          map[lastIdx].dirs[d] = nil
        if map[idx] and map[idx].dirs
          didCost = true
          map[idx].dirs[dir_opposite(d)] = nil

        if didCost
          money -= destructionCost
      else
        map[lastIdx] or= {}
        map[lastIdx].road = true
        map[lastIdx].dirs or= {}
        unless map[lastIdx].dirs[d]
          didCost = true
        map[lastIdx].dirs[d] = true
        map[idx] or= {}
        map[idx].road = true
        map[idx].dirs or= {}
        unless map[idx].dirs[dir_opposite(d)]
          didCost = true
        map[idx].dirs[dir_opposite(d)] = true

        if didCost
          money -= roadCost
      
      buildRoads!

  text = "started #{startedAt.hour}:#{startedAt.min}:#{startedAt.sec} | step #{stepIndex} | money $#{money}"

updateSim = (dt) ->
  roundTicks += dt
  if roundTicks > 0.1
    roundTicks -= 0.1
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
        currentBuilding = nil
      )
    }
    table.insert uiObjects, obj

  for b in *(buildings[buildingTab])
    obj = {
      loc: "palette"
      icon: images.buildings[b.name]
      onclick: (->
        currentBuilding = b
      )
    }
    unless obj.icon 
      error("could not find icon for building #{b}")
    table.insert uiObjects, obj
    -- io.write "added building #{b}, now has #{#uiObjects} ui objects\n"

  for i=1,numCols
    for j=1,numRows
      if c = map[i+(j-1)*numCols]
        obj = {
          :i, :j
          loc: "map"
          building: c.building
        }
        if c.road
          obj.roadIcon = images.roads[c.road]
        if c.building
          obj.icon = images.buildings[c.building.name]

        table.insert uiObjects, obj

  for i=1,numCols
    for j=1,numRows
      table.insert uiObjects, {
        :i, :j
        loc: "map"
        meta: true
        icon: images.buttons.slot
        onclick: (->
          if currentBuilding
            idx = i+(j-1)*numCols
            map[idx] or= {}
            map[idx].building = currentBuilding
            buildUI!
        )
      }

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
  for i=1,numCols*numRows
    map[i] = nil

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
      if obj.hover
        graphics.setColor 0.4, 0.4, 1.0
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
        if obj.loc == "map" and not obj.meta
          graphics.draw images.buildings.bg, x, y, angle, scale, scale
        graphics.draw icon, x, y, angle, scale, scale
      else if icon = obj.roadIcon
        graphics.draw icon, x, y, angle, scale, scale

  -- do
  --   half = slotSide / 2
  --   for i=1,numCols
  --     for j=1,numRows
  --       if c = map[i+(j-1)*numCols]
  --         if dirs = c.dirs
  --           x, y = object_world_pos i, j
  --           for d in pairs dirs
  --             angle = dir_to_angle d
  --             graphics.reset!
  --             graphics.setColor 0.7, 0.7, 1
  --             ox = half
  --             oy = half
  --             scale = 0.8
  --             graphics.draw images.misc.arrow, x + half, y + half, angle, scale, scale, ox, oy

  do
    x, y = mouse.getPosition!
    graphics.reset!
    img = images.cursors[currentCursor]
    graphics.draw img, x, y
    if currentBuilding
      img = images.buildings[currentBuilding.name]
      scale = 0.5
      x += 16
      y += 16
      graphics.setColor 0.6, 1.0, 0.6, 0.8
      graphics.draw img, x, y, 0, scale, scale

love.draw = ->
  drawFG!
  drawUI!

newImage = (path) ->
  img = graphics.newImage path
  unless img
    error("image not found: #{img}")
  io.write "loaded #{path}\n"
  img
