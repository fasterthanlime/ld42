
import graphics, mouse from require "love"
imgs = require "imgs"
utils = require "utils"
constants = require "constants"
draw_indic = require "draw_indic"

draw_units = (state) ->
  for u in *state.map.units
    graphics.reset!
    {:i, :j, :d, :angle} = u
    x, y = utils.object_world_pos i, j
    unitHalf = constants.map.unit_side/2
    ox, oy = unitHalf, unitHalf

    slotHalf = constants.map.slot_side/2
    original_x = x
    original_y = y
    x += slotHalf
    y += slotHalf
    scale = 1
    img = imgs.get u.unit.name
    graphics.draw img, x, y, angle, scale, scale, ox, oy

    space_avail = u.unit.capacity
    space_taken = 0
    for k, v in pairs u.materials
      space_taken += v

    occupancy = space_taken / space_avail

    draw_indic 10, original_x, original_y-20, occupancy

draw_units
