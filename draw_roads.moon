
utils = require "utils"
{:log} = utils
pprint = require "pprint"
constants = require "constants"

draw_roads = (state, old_hover, new_hover) ->
  return unless state.ui.pressed
  return unless state.tool.name == "road"
  return unless old_hover and new_hover
  return unless old_hover.meta and new_hover.meta
  return if old_hover == new_hover

  diff_i, diff_j = utils.obj_ij_diff old_hover, new_hover
  d = utils.vec_to_dir diff_i, diff_j
  return unless d

  {x, y} = utils.dir_to_vec d
  old_idx = utils.ij_to_index old_hover.i, old_hover.j
  new_idx = utils.ij_to_index new_hover.i, new_hover.j

  old_c = state.map.cells[old_idx]
  new_c = state.map.cells[new_idx]

  return if new_c.building and new_c.building.terrain
  return if old_c.building and old_c.building.terrain
  -- log "old_idx = #{old_idx}, new_idx = #{new_idx}"

  did_cost = false

  od = utils.dir_opposite(d)

  if utils.is_shift_down!
    -- delete roads
    utils.remove_dir old_c, d
    utils.remove_dir new_c, od
  else
    -- add roads
    if not (utils.has_dir(old_c, d) and utils.has_dir(new_c, od))
      if utils.spend state, constants.road_cost, "build roads"
        utils.add_dir old_c, d
        utils.add_dir new_c, od
  return true

draw_roads
