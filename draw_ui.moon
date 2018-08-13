
import graphics, mouse from require "love"
imgs = require "imgs"
utils = require "utils"
constants = require "constants"

draw_ui = (state) ->
  graphics.reset!
  graphics.setColor 1, 1, 1
  graphics.print state.ui.status_text, 20, constants.screen_h-30

  do 
    for obj in *state.ui.objects
      graphics.reset!
      if obj.hover and not obj.protected
        graphics.setColor 0.8, 0.8, 1.0
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
          graphics.draw imgs.get("button-bg"), x, y, angle, scale, scale
      if icon = obj.icon
        graphics.draw imgs.get(icon), x, y, angle, scale, scale
      else if icon = obj.road_icon
        graphics.draw imgs.get(icon), x, y, angle, scale, scale

draw_ui
