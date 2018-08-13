local graphics, mouse
do
  local _obj_0 = require("love")
  graphics, mouse = _obj_0.graphics, _obj_0.mouse
end
local imgs = require("imgs")
local utils = require("utils")
local constants = require("constants")
local draw_indic = require("draw_indic")
local draw_ui
draw_ui = function(state)
  graphics.reset()
  graphics.setColor(1, 1, 1)
  graphics.setFont(constants.big_font)
  graphics.print(state.ui.main_text, 20, constants.screen_h - 60)
  graphics.reset()
  graphics.setColor(1, 1, 1)
  graphics.print(state.ui.status_text, 20, constants.screen_h - 25)
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
        local icon = obj.road_icon
        if icon then
          graphics.draw(imgs.get(icon), x, y, angle, scale, scale)
        end
      end
      do
        local icon = obj.icon
        if icon then
          graphics.draw(imgs.get(icon), x, y, angle, scale, scale)
        end
      end
      if obj.loc == "palette" then
        if state.money >= obj.cost then
          graphics.setColor(0.6, 1, 0.6)
        else
          graphics.setColor(1, 0.6, 0.6)
        end
        graphics.print("$" .. tostring(obj.cost), x, y + 55)
      end
      if obj.loc == "map" then
        local i, j
        i, j = obj.i, obj.j
        local idx = utils.ij_to_index(i, j)
        local c = state.map.cells[idx]
        do
          local b = c.building
          if b then
            if b.inputs and b.output then
              local cur = c.bstate.materials[b.output.name]
              local max = constants.max_output
              local perc = cur / max
              draw_indic(40, x, y, perc)
            end
          end
        end
      end
    end
  end
end
return draw_ui
