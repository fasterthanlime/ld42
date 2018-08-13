
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
      if utils.is_shift_down!
        graphics.setColor 1.0, 0.6, 0.6, 1
      else
        graphics.setColor 0.6, 1.0, 0.6, 1
      graphics.draw img, x, y, 0, scale, scale