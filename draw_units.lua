local graphics, mouse
do
  local _obj_0 = require("love")
  graphics, mouse = _obj_0.graphics, _obj_0.mouse
end
local imgs = require("imgs")
local utils = require("utils")
local constants = require("constants")
local draw_indic = require("draw_indic")
local draw_units
draw_units = function(state)
  local _list_0 = state.map.units
  for _index_0 = 1, #_list_0 do
    local u = _list_0[_index_0]
    graphics.reset()
    local i, j, d, angle
    i, j, d, angle = u.i, u.j, u.d, u.angle
    local x, y = utils.object_world_pos(i, j)
    local unitHalf = constants.map.unit_side / 2
    local ox, oy = unitHalf, unitHalf
    local slotHalf = constants.map.slot_side / 2
    local original_x = x
    local original_y = y
    x = x + slotHalf
    y = y + slotHalf
    local scale = 1
    local img = imgs.get(u.unit.name)
    graphics.draw(img, x, y, angle, scale, scale, ox, oy)
    local space_avail = u.unit.capacity
    local space_taken = 0
    for k, v in pairs(u.materials) do
      space_taken = space_taken + v
    end
    local occupancy = space_taken / space_avail
    draw_indic(30, original_x, original_y - 20, occupancy)
  end
end
return draw_units
