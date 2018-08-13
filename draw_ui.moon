
import graphics, mouse from require "love"
imgs = require "imgs"
utils = require "utils"
constants = require "constants"
draw_indic = require "draw_indic"

draw_ui = (state) ->
  graphics.reset!
  graphics.setFont constants.big_font

  do
    graphics.setColor 1, 1, 1
    graphics.print state.ui.paused_text, 20, constants.screen_h-70

    graphics.setColor 0.4, 1, 0.4
    graphics.print state.ui.money_text, 300, constants.screen_h-70

    graphics.setColor 0.4, 0.4, 1
    graphics.print state.ui.units_text, 600, constants.screen_h-70

  graphics.reset!
  graphics.setColor 1, 1, 1
  graphics.print state.ui.status_text, 20, constants.screen_h-25

  do 
    for obj in *state.ui.objects
      graphics.reset!
      alpha = 1
      if obj.loc == "map"
        alpha = 0.7

      if obj.hover and not obj.protected
        graphics.setColor 0.8, 0.8, 1.0, alpha
      else
        graphics.setColor 1, 1, 1, alpha
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
        graphics.print "#{utils.format_price(obj.cost)}", x, y+55

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
