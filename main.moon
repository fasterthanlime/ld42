lick = require "lick"
lick.reset = true -- reload game every time it's compiled

import graphics, mouse from love

text = ""
startedAt = nil

love.load = ->
  startedAt = os.date('*t')
  font = graphics.newFont "fonts/BeggarsExtended.ttf", 36
  graphics.setFont font

love.draw = ->
  graphics.print(text, 20, 20)

love.update = (dt) ->
  x, y = mouse.getPosition()
  text = "started at #{startedAt.hour}:#{startedAt.min}:#{startedAt.sec}, mouse is at #{x}, #{y}"

