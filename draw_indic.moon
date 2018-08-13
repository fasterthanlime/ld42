
import graphics from require "love"

draw_indic = (width, x, y, perc) ->
  outer = width
  inner = (outer-2) * perc
  indic_height = 4

  x += (60 - outer)/2
  y += 50

  graphics.setColor 0.8, 0.8, 0.8
  graphics.rectangle "fill", x, y, outer, 4

  graphics.setColor 0.4, 0.4, 1.0
  graphics.rectangle "fill", x+1, y+1, inner, 2

draw_indic
