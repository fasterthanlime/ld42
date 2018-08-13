local utils = require("utils")
local constants = require("constants")
local buildings = require("buildings")
local units = require("units")
local pprint = require("pprint")
local log, Dir
log, Dir = utils.log, utils.Dir
local standard_buttons = {
  pause = {
    loc = "toolbar",
    icon = "pause",
    onclick = (function(state)
      log("pausing")
      state.sim.paused = true
      return {
        build_ui = true
      }
    end)
  },
  play = {
    loc = "toolbar",
    icon = "play",
    onclick = (function(state)
      log("resuming")
      state.sim.paused = false
      return {
        build_ui = true
      }
    end)
  }
}
local build_ui
build_ui = function(state)
  local objects = { }
  if state.sim.paused then
    table.insert(objects, standard_buttons.play)
  else
    table.insert(objects, standard_buttons.pause)
  end
  do
    local obj = {
      loc = "palette",
      icon = "road-left-right",
      onclick = (function(state)
        state.tool = {
          name = "road"
        }
        return {
          build_ui = true
        }
      end)
    }
    table.insert(objects, obj)
  end
  local _list_0 = (buildings[state.ui.building_tab])
  for _index_0 = 1, #_list_0 do
    local b = _list_0[_index_0]
    local obj = {
      loc = "palette",
      icon = b.name,
      onclick = (function(state)
        state.tool = {
          name = "building",
          building = b
        }
        return {
          build_ui = true
        }
      end)
    }
    if not (obj.icon) then
      error("could not find icon for building " .. tostring(b))
    end
    table.insert(objects, obj)
  end
  for _index_0 = 1, #units do
    local u = units[_index_0]
    local obj = {
      loc = "palette",
      icon = u.name,
      onclick = (function(state)
        state.tool = {
          name = "unit",
          unit = u
        }
        return {
          build_ui = true
        }
      end)
    }
    table.insert(objects, obj)
  end
  for i = 1, constants.num_cols do
    for j = 1, constants.num_rows do
      table.insert(objects, {
        i = i,
        j = j,
        loc = "map",
        meta = true,
        icon = "slot",
        onclick = (function(state)
          log("slot clicked! tool =")
          pprint(state.tool)
          local _exp_0 = state.tool.name
          if "road" == _exp_0 then
            return nil
          elseif "unit" == _exp_0 then
            if state.tool.unit then
              return table.insert(state.map.units, {
                i = i,
                j = j,
                d = Dir.u,
                angle = 0,
                unit = state.tool.unit
              })
            end
          elseif "building" == _exp_0 then
            local idx = utils.ij_to_index(i, j)
            local c = state.map.cells[idx]
            if c and c.protected then
              return 
            end
            if utils.is_shift_down() then
              c.building = nil
              return {
                build_ui = true
              }
            else
              c.building = state.tool.building
              return {
                build_ui = true
              }
            end
          end
        end)
      })
    end
  end
  for i = 1, constants.num_cols do
    for j = 1, constants.num_rows do
      local idx = utils.ij_to_index(i, j)
      do
        local c = state.map.cells[idx]
        if c then
          local obj = {
            i = i,
            j = j,
            loc = "map",
            building = c.building,
            protected = c.protected
          }
          if c.road then
            obj.road_icon = c.road
          end
          if c.building then
            obj.icon = c.building.name
          end
          table.insert(objects, obj)
        end
      end
    end
  end
  do
    local toolbar_x = 10
    local toolbar_y = 10
    local palette_base_x = constants.screen_w - constants.palette.total_width
    local palette_x = constants.palette.initial_x
    local palette_y = 100
    local palette_n = 0
    for i, obj in ipairs(objects) do
      if not (obj) then
        error("ui object " .. tostring(i) .. " is nil")
      end
      obj.hover = false
      local _exp_0 = obj.loc
      if "toolbar" == _exp_0 then
        obj.x = toolbar_x
        obj.y = toolbar_y
        obj.w = 40
        obj.h = 40
        toolbar_x = toolbar_x + 50
      elseif "palette" == _exp_0 then
        obj.x = palette_x + palette_base_x
        obj.y = palette_y
        obj.w = constants.palette.item_side
        obj.h = constants.palette.item_side
        palette_n = palette_n + 1
        palette_x = palette_x + (constants.palette.item_side + constants.palette.item_spacing)
        if palette_n >= constants.palette.items_per_row then
          palette_n = 0
          palette_x = constants.palette.initial_x
          palette_y = palette_y + (constants.palette.item_side + constants.palette.item_spacing)
        end
      elseif "map" == _exp_0 then
        obj.x, obj.y = utils.object_world_pos(obj.i, obj.j)
        obj.w, obj.h = constants.map.slot_side, constants.map.slot_side
      else
        error("unknown location " .. tostring(obj.loc))
      end
    end
  end
  state.ui.objects = objects
end
return build_ui
