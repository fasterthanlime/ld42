lick = require "lick"
lick.reset = true -- reload game every time it's compiled

import CheckCollision from require "utils"
import graphics, physics, mouse from love

local buildUI

screenWidth = 800
screenHeight = 800

world = nil
objects = {}
text = ""
startedAt = nil
font = nil
paused = true
roundTicks = 0
stepIndex = 0

uiObjects = {}

cursors = {
  "pointer"
  "hand"
  "tri-bottomleft"
  "tri-bottomright"
}
currentCursor = 1

buttons = {
  "play"
  "pause"
}
buttonExtras = {
  "toolbar"
  "bg"
}

images = {}

uiObjectTouchesMouse = (obj) ->
  x, y = mouse.getPosition!
  CheckCollision(x-2, y-2, 4, 4, obj.x, obj.y, obj.w, obj.h)

step = ->
  stepIndex += 1

updateUI = ->
  for obj in *uiObjects
    obj.hover = uiObjectTouchesMouse(obj)
  text = "started #{startedAt.hour}:#{startedAt.min}:#{startedAt.sec} | step #{stepIndex}"

updateSim = (dt) ->
  world\update dt
  roundTicks += dt
  if roundTicks > 0.5
    roundTicks -= 0.5
    step()

love.update = (dt) ->
  unless paused
    updateSim dt
  updateUI!

love.wheelmoved = (x, y) ->
  if y > 0
    currentCursor -= 1
  else if y < 0
    currentCursor += 1
  currentCursor = math.min(#cursors, math.max(1, currentCursor))

love.mousepressed = (x, y, button, istouch, presses) ->
  for obj in *uiObjects
    if uiObjectTouchesMouse(obj) and obj.onclick
      obj.onclick!

makeButton = (icon, onclick) ->
  {
    loc: "toolbar"
    :icon
    :onclick
  }

standardButtons = {
  pause: {
    loc: "toolbar"
    icon: "pause"
    onclick: (->
      paused = true
      buildUI!
    )
  }
  play: {
    loc: "toolbar"
    icon: "play"
    onclick: (->
      paused = false
      buildUI!
    )
  }
}

buildUI = ->
  uiObjects = {}

  if paused
    table.insert uiObjects, standardButtons.play
  else
    table.insert uiObjects, standardButtons.pause

  -- now do layout
  do
    toolbarX = 10
    toolbarY = 10

    for obj in *uiObjects
      switch obj.loc
        when "toolbar"
          obj.x = toolbarX
          obj.y = toolbarY
          obj.w = 40
          obj.h = 40
          obj.hover = false
          toolbarX += 50

love.load = ->
  mouse.setVisible false
  startedAt = os.date '*t' 
  font = graphics.newFont "fonts/BeggarsExtended.ttf", 28

  physics.setMeter 64 
  world = physics.newWorld 0, 9.18*64, true 

  objects.ball = {}
  objects.ball.body = physics.newBody world, 650/2, 650/2, "dynamic"
  objects.ball.shape = physics.newCircleShape 20
  objects.ball.fixture = physics.newFixture objects.ball.body, objects.ball.shape, 1
  objects.ball.fixture\setRestitution 0.9

  images.cursors = {}
  for k in *cursors
    images.cursors[k] = graphics.newImage "art/cursors/#{k}.png"

  images.buttons = {}
  for k in *buttons
    images.buttons[k] = graphics.newImage "art/buttons/#{k}.png"

  images.buttonExtras = {}
  for k in *buttonExtras
    images.buttonExtras[k] = graphics.newImage "art/buttons/#{k}.png"

  buildUI!

drawBG = ->
  do
    offY = 80
    offX = 60
    side = 60
    halfSide = side / 2
    graphics.setColor 0.2, 0.2, 0.2

    for i=0,10
      for j=0,10
        x = i * halfSide*2 + halfSide + offX
        y = j * halfSide*2 + halfSide + offY
        graphics.circle "fill", x, y, halfSide-2

drawFG = ->
  if ball = objects.ball
    graphics.setColor 0.76, 0.18, 0.05
    graphics.circle "fill", ball.body\getX!, ball.body\getY!, ball.shape\getRadius!

drawUI = ->
  graphics.reset!
  graphics.setColor 1, 1, 1
  graphics.setFont font
  graphics.print text, 20, 800-40

  do 
    graphics.reset!
    graphics.draw images.buttonExtras.toolbar, 0, 0

    for obj in *uiObjects
      graphics.reset!
      if obj.hover
        graphics.setColor 1, 1, 1
      else
        graphics.setColor 0.9, 0.9, 0.9
      x, y = obj.x, obj.y
      graphics.draw images.buttonExtras.bg, x, y
      graphics.reset!
      graphics.draw images.buttons[obj.icon], x, y

  do
    x, y = mouse.getPosition!
    graphics.reset!
    img = images.cursors[cursors[currentCursor]]
    graphics.draw img, x, y

love.draw = ->
  drawBG!
  drawFG!
  drawUI!
