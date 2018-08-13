local utils = require("utils")
local log
log = utils.log
local pprint = require("pprint")
local constants = require("constants")
local draw_roads
draw_roads = function(state, old_hover, new_hover)
  if not (state.ui.pressed) then
    return 
  end
  if not (state.tool.name == "road") then
    return 
  end
  if not (old_hover and new_hover) then
    return 
  end
  if old_hover == new_hover then
    return 
  end
  local diff_i, diff_j = utils.obj_ij_diff(old_hover, new_hover)
  local d = utils.vec_to_dir(diff_i, diff_j)
  if not (d) then
    return 
  end
  local x, y
  do
    local _obj_0 = utils.dir_to_vec(d)
    x, y = _obj_0[1], _obj_0[2]
  end
  local old_idx = utils.ij_to_index(old_hover.i, old_hover.j)
  local new_idx = utils.ij_to_index(new_hover.i, new_hover.j)
  local old_c = state.map.cells[old_idx]
  local new_c = state.map.cells[new_idx]
  if new_c.building and new_c.building.terrain then
    return 
  end
  if old_c.building and old_c.building.terrain then
    return 
  end
  log("old_idx = " .. tostring(old_idx) .. ", new_idx = " .. tostring(new_idx))
  local did_cost = false
  if utils.is_shift_down() then
    local c1 = utils.remove_dir(old_c, d)
    local c2 = utils.remove_dir(new_c, utils.dir_opposite(d))
    if c1 or c2 then
      state.money = state.money - constants.destruction_cost
    end
  else
    local c1 = utils.add_dir(old_c, d)
    local c2 = utils.add_dir(new_c, utils.dir_opposite(d))
    if c1 or c2 then
      state.money = state.money - constants.road_cost
    end
  end
  return true
end
return draw_roads
