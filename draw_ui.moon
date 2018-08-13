
import graphics, mouse from require "love"
imgs = require "imgs"
utils = require "utils"

draw_ui = (state) ->
  graphics.reset!
  graphics.setColor 1, 1, 1
  graphics.print text, 20, screenHeight-30

  do 
    for obj in *state.ui.objects
      graphics.reset!
      if obj.hover and not obj.protected and obj.loc != "map"
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
          graphics.draw img.get("button-bg"), x, y, angle, scale, scale
      if icon = obj.icon
        graphics.draw img.get(icon), x, y, angle, scale, scale
      else if icon = obj.roadIcon
        graphics.draw img.get(icon), x, y, angle, scale, scale
