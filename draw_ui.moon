
import graphics, mouse from require "love"
imgs = require "imgs"
utils = require "utils"
constants = require "constants"
draw_indic = require "draw_indic"

draw_ui = (state) ->
  graphics.reset!
  graphics.setColor 1, 1, 1
  graphics.setFont constants.big_font
  graphics.print state.ui.main_text, 20, constants.screen_h-60

  graphics.reset!
  graphics.setColor 1, 1, 1
  graphics.print state.ui.status_text, 20, constants.screen_h-25

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
      if icon = obj.road_icon
        graphics.draw imgs.get(icon), x, y, angle, scale, scale
      if icon = obj.icon
        graphics.draw imgs.get(icon), x, y, angle, scale, scale

      if obj.loc == "palette"
        if state.money >= obj.cost
          graphics.setColor 0.6, 1, 0.6
        else
          graphics.setColor 1, 0.6, 0.6
        graphics.print "$#{obj.cost}", x, y+55

      if obj.loc == "map"
        {:i, :j} = obj
        idx = utils.ij_to_index i, j
        c = state.map.cells[idx]
        if b = c.building
          if b.inputs and b.output
            cur = c.bstate.materials[b.output.name]
            max = constants.max_output
            perc = cur/max
            draw_indic 40, x, y, perc

draw_ui
