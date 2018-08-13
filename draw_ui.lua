local graphics, mouse
do
  local _obj_0 = require("love")
  graphics, mouse = _obj_0.graphics, _obj_0.mouse
end
local imgs = require("imgs")
local utils = require("utils")
local constants = require("constants")
local draw_ui
draw_ui = function(state)
  graphics.reset()
  graphics.setColor(1, 1, 1)
  graphics.print(state.ui.status_text, 20, constants.screen_h - 30)
  do
    local _list_0 = state.ui.objects
    for _index_0 = 1, #_list_0 do
      local obj = _list_0[_index_0]
      graphics.reset()
      if obj.hover and not obj.protected then
        graphics.setColor(0.8, 0.8, 1.0)
      else
        graphics.setColor(1, 1, 1)
      end
      local x, y
      x, y = obj.x, obj.y
      local scale = 1
      local angle = 0
      local _exp_0 = obj.loc
      if "palette" == _exp_0 then
        scale = 0.75
        angle = obj.hover and 0 or 3.14 * 1 / 64
      end
      local _exp_1 = obj.loc
      if "toolbar" == _exp_1 then
        graphics.draw(imgs.get("button-bg"), x, y, angle, scale, scale)
      end
      do
        local icon = obj.icon
        if icon then
          graphics.draw(imgs.get(icon), x, y, angle, scale, scale)
        else
          do
            icon = obj.road_icon
            if icon then
              graphics.draw(imgs.get(icon), x, y, angle, scale, scale)
            end
          end
        end
      end
    end
  end
end
return draw_ui
