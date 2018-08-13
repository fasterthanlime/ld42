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
  if not (old_hover.meta and new_hover.meta) then
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
  local did_cost = false
  local od = utils.dir_opposite(d)
  if utils.is_shift_down() then
    utils.remove_dir(old_c, d)
    utils.remove_dir(new_c, od)
  else
    if not (utils.has_dir(old_c, d) and utils.has_dir(new_c, od)) then
      if utils.spend(state, constants.road_cost, "build roads") then
        utils.add_dir(old_c, d)
        utils.add_dir(new_c, od)
      end
    end
  end
  return true
end
return draw_roads
