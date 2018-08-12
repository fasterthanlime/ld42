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

  for i=0,numCols
    for j=0,numRows
      if b = map[i+j*numCols]
        table.insert uiObjects, {
          :i, :j
          loc: "map"
          icon: images.buildings[b]
        }

  for i=0,numCols
    for j=0,numRows
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
  for i=0,numCols*numRows
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
