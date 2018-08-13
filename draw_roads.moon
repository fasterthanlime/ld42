
utils = require "utils"

draw_roads = (state, old_hover, new_hover) ->
  return unless state.tool.name == "road"
  return unless pressed
  return unless old_hover and new_hover
  return if old_hover == new_hover

  diff_i, diff_j = utils.obj_ij_diff old_hover, new_hover
  d = vec_to_dir diff_i, diff_j
  return unless d

  {x, y} = utils.dir_to_vec d
  old_idx = utils.ij_to_idx old_hover.i, old_hover.j
  new_idx = utils.ij_to_idx new_hover.i, new_hover.j

  old_c = state.map.cells[old_idx]
  new_c = state.map.cells[new_idx]

  return if new_c.building and new_c.building.terrain
  return if old_c.building and old_c.building.terrain

  did_cost = false

  if utils.is_shift_down!
    -- delete roads
    did_cost or= utils.remove_dir old_c, d
    did_cost or= utils.remove_dir new_c, utils.dir_opposite(d)

    if did_cost
      state.money -= constants.destruction_cost
  else
    -- add roads
    did_cost or= utils.add_dir old_c, d
    did_cost or= utils.add_dir new_c, utils.dir_opposite(d)

    if did_cost
      state.money -= constants.road_cost
  return true
