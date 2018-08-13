
import graphics, mouse from require "love"
imgs = require "imgs"
utils = require "utils"

draw_units = (state) ->
  graphics.reset!

  for u in *mapUnits
    {:i, :j, :d, :angle} = u
    x, y = object_world_pos i, j
    unitHalf = unitSide/2
    ox, oy = unitHalf, unitHalf

    slotHalf = slotSide/2
    x += slotHalf
    y += slotHalf
    scale = 1
    img = images.units[u.unit.name]
    graphics.draw img, x, y, angle, scale, scale, ox, oy