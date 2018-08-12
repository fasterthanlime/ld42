lick = require "lick"
lick.reset = true -- reload game every time it's compiled

import CheckCollision from require "utils"
import graphics, mouse from love

local buildUI
local newImage

numCols = 10
numRows = 10
slotSide = 60

initialMapX = 30
initialMapY = 80

screenWidth = 1000
screenHeight = 800

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
buildingTab = "road"
hasHover = false

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
  culture: {
    "cinema"
    "library"
  }
  infra: {
    "power-plant"
  }
  road: {
    "road-i"
    "road--"
    "road-t"
    "road-left-top"
    "road-left-bottom"
    "road-right-top"
    "road-right-bottom"
  }
  misc: {
    "arrow"
  }
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

road_mappings = {
  "road-i": {dir.u, dir.d},
  "road--": {dir.l, dir.r},
  "road-t": {dir.u, dir.d, dir.l, dir.r},
  "road-left-top": {dir.l, dir.u},
  "road-left-bottom": {dir.l, dir.d},
  "road-right-top": {dir.r, dir.u},
  "road-right-bottom": {dir.r, dir.d},
}

images = {}

uiObjectTouchesMouse = (obj) ->
  x, y = mouse.getPosition!
  CheckCollision(x-2, y-2, 4, 4, obj.x, obj.y, obj.w, obj.h)

step = ->
  stepIndex += 1

updateUI = ->
  hasHover = false
  for obj in *uiObjects
    if obj.onclick
      if obj.hover = uiObjectTouchesMouse(obj)
        hasHover = true
        break

  if hasHover
    currentCursor = "hand"
  else
    currentCursor = "pointer"
  text = "started #{startedAt.hour}:#{startedAt.min}:#{startedAt.sec} | step #{stepIndex}"

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
  for obj in *uiObjects
    if uiObjectTouchesMouse(obj) and obj.onclick
      obj.onclick!

local standardButtons

buildUI = ->
  uiObjects = {}

  if paused
    table.insert uiObjects, standardButtons.play
  else
    table.insert uiObjects, standardButtons.pause

  for b in *(buildings[buildingTab])
    obj = {
      loc: "palette"
      icon: images.buildings[b]
      onclick: (->
        currentBuilding = b
      )
    }
    unless obj.icon 
      error("could not find icon for building #{b}")
    table.insert uiObjects, obj
    io.write "added building #{b}, now has #{#uiObjects} ui objects\n"

  for i=1,numCols
    for j=1,numRows
      if b = map[i+j*numCols]
        table.insert uiObjects, {
          :i, :j
          loc: "map"
          icon: images.buildings[b]
          building: b
        }

  for i=1,numCols
    for j=1,numRows
      table.insert uiObjects, {
        :i, :j
        loc: "map"
        icon: images.buttons.slot
        onclick: (->
          if currentBuilding
            map[i+j*numCols] = currentBuilding
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
      unless obj.icon
        error("uiObject #{i} has nil icon (loc #{obj.loc}, onclick #{obj.onclick})")

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
          obj.x = initialMapX + obj.i * slotSide
          obj.y = initialMapY + obj.j * slotSide
          obj.w = slotSide
          obj.h = slotSide
        else
          error("unknown location #{obj.loc}")

love.load = ->
  for i=1*numCols,numCols*numRows
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
    for k in *catBuildings
      images.buildings[k] = newImage "art/buildings/#{k}.png"

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
  graphics.setFont font
  graphics.print text, 20, 800-40

  do 
    for obj in *uiObjects
      graphics.reset!
      if obj.hover
        graphics.setColor 1, 1, 1
      else
        graphics.setColor 0.8, 0.8, 0.8
      x, y = obj.x, obj.y

      scale = 1
      angle = 0

      switch obj.loc 
        when "palette"
          scale = 0.75
          angle = obj.hover and 0 or 3.14 * 1/64

      switch obj.loc 
        when "toolbar"
          graphics.draw images.buttonExtras.bg, x, y, angle, scale, scale

      graphics.draw obj.icon, x, y, angle, scale, scale
    
  do
    half = slotSide / 2
    for obj in *uiObjects
      if b = obj.building
        x, y = obj.x, obj.y
        if dirs = road_mappings[b]
          for d in *dirs
            angle = dir_to_angle d
            graphics.reset!
            graphics.setColor 0.6, 0.6, 1
            ox = half
            oy = half
            scale = 1
            graphics.draw images.buildings.arrow, x + half, y + half, angle, scale, scale, ox, oy

  do
    x, y = mouse.getPosition!
    graphics.reset!
    img = images.cursors[currentCursor]
    graphics.draw img, x, y
    if currentBuilding
      img = images.buildings[currentBuilding]
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
