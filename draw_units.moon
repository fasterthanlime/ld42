
import graphics, mouse from require "love"
imgs = require "imgs"
utils = require "utils"
constants = require "constants"

draw_units = (state) ->
  graphics.reset!

  for u in *state.map.units
    {:i, :j, :d, :angle} = u
    x, y = utils.object_world_pos i, j
    unitHalf = constants.map.unit_side/2
    ox, oy = unitHalf, unitHalf

    slotHalf = constants.map.slot_side/2
    x += slotHalf
    y += slotHalf
    scale = 1
    img = imgs.get u.unit.name
    graphics.draw img, x, y, angle, scale, scale, ox, oy

draw_units