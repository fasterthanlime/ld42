local graphics
graphics = require("love").graphics
local draw_indic
draw_indic = function(width, x, y, perc)
  local outer = width
  local inner = (outer - 2) * perc
  local indic_height = 4
  x = x + ((60 - outer) / 2)
  y = y + 50
  graphics.setColor(0.8, 0.8, 0.8)
  graphics.rectangle("fill", x, y, outer, 4)
  graphics.setColor(0.4, 0.4, 1.0)
  return graphics.rectangle("fill", x + 1, y + 1, inner, 2)
end
return draw_indic
