local graphics, mouse
do
  local _obj_0 = require("love")
  graphics, mouse = _obj_0.graphics, _obj_0.mouse
end
local imgs = require("imgs")
local utils = require("utils")
local draw_mouse
draw_mouse = function(state)
  local x, y = mouse.getPosition()
  local img = imgs.get(state.ui.cursor)
  graphics.reset()
  graphics.draw(img, x, y)
  do
    img = nil
    local _exp_0 = state.tool.name
    if "building" == _exp_0 then
      img = imgs.get(state.tool.building.name)
    elseif "unit" == _exp_0 then
      img = imgs.get(state.tool.unit.name)
    elseif "road" == _exp_0 then
      img = imgs.get("road-left-right")
    end
    if img then
      local scale = 0.5
      x = x + 16
      y = y + 16
      if utils.is_shift_down() then
        graphics.setColor(1.0, 0.6, 0.6, 1)
      else
        graphics.setColor(0.6, 1.0, 0.6, 1)
      end
      return graphics.draw(img, x, y, 0, scale, scale)
    end
  end
end
return draw_mouse
