
import graphics, mouse from require "love"
imgs = require "imgs"
utils = require "utils"

draw_mouse = (state) ->
  x, y = mouse.getPosition!
  img = imgs.get state.ui.cursor
  graphics.reset!
  graphics.draw img, x, y

  do
    img = nil
    switch state.tool.name
      when "building"
        img = imgs.get state.tool.building.name
      when "unit"
        img = imgs.get state.tool.unit.name
      when "road"
        img = imgs.get "road-left-right"

    if img
      scale = 0.5
      x += 16
      y += 16
      if utils.is_shift_down!
        graphics.setColor 1.0, 0.6, 0.6, 1
      else
        graphics.setColor 0.6, 1.0, 0.6, 1
      graphics.draw img, x, y, 0, scale, scale

draw_mouse