
utils = require "utils"
constants = require "constants"
buildings = require "buildings"
units = require "units"
pprint = require "pprint"
{:log, :Dir} = utils

standard_buttons = {
  pause: {
    loc: "toolbar"
    icon: "pause"
    onclick: ((state) ->
      log "pausing"
      state.sim.paused = true
      return {build_ui: true}
    )
  }
  play: {
    loc: "toolbar"
    icon: "play"
    onclick: ((state) ->
      log "resuming"
      state.sim.paused = false
      return {build_ui: true}
    )
  }
  restart: {
    loc: "toolbar"
    icon: "restart"
    onclick: ((state) ->
      log "restarting"
      return {restart: true}
    )
  }
  clear_units: {
    loc: "toolbar"
    icon: "clear-units"
    onclick: ((state) ->
      state.map.units = {}
      log "clearing all units"
      return {}
    )
  }
}

-- React-ish 'render' method, rebuilds `state.ui.objects` from
-- scratch with:
--   - toolbar elements (topmost)
--   - palette elements (right)
--   - map elements
build_ui = (state) ->
  objects = {}

  --------------------------------
  -- toolbar
  --------------------------------
  if state.sim.paused
    table.insert objects, standard_buttons.play
  else
    table.insert objects, standard_buttons.pause
  table.insert objects, standard_buttons.clear_units
  table.insert objects, standard_buttons.restart

  --------------------------------
  -- palette
  --------------------------------
  for u in *units
    obj = {
      loc: "palette"
      icon: u.name
      cost: u.cost
      onclick: ((state) ->
        state.tool = {name: "unit", unit: u}
        return {build_ui: true}
      )
    }
    table.insert objects, obj

  do
    obj = {
      loc: "palette"
      icon: "road-left-right"
      cost: constants.road_cost
      onclick: ((state)->
        state.tool = {name: "road"}
        return {build_ui: true}
      )
    }
    table.insert objects, obj

  for b in *(buildings[state.ui.building_tab])
    obj = {
      loc: "palette"
      icon: b.name
      cost: b.cost
      onclick: ((state) ->
        state.tool = {name: "building", building: b}
        return {build_ui: true}
      )
    }
    unless obj.icon 
      error("could not find icon for building #{b}")
    table.insert objects, obj

  --------------------------------
  -- map
  --------------------------------
  for i=1,constants.num_cols
    for j=1,constants.num_rows
      table.insert objects, {
        :i, :j
        loc: "map"
        meta: true
        icon: "slot"
        onclick: ((state) ->
          log "slot clicked! tool ="
          pprint state.tool
          switch state.tool.name
            when "road"
              nil -- muffin
            when "unit"
              if #state.map.units >= constants.max_units
                status_text = "too many units! hit the 'clear units' button"
                return
              if state.tool.unit
                if utils.spend state, state.tool.unit.cost, "purchase #{state.tool.unit.name}"
                  table.insert state.map.units, {
                    :i, :j
                    d: Dir.u
                    angle: 0
                    unit: state.tool.unit
                    materials: {}
                  }
            when "building"
              idx = utils.ij_to_index i, j
              c = state.map.cells[idx]
              return if c.protected
              if utils.is_shift_down! and c.building
                c.building = nil
                return {build_ui: true}
              else
                if utils.spend state, state.tool.building.cost, "build #{state.tool.building.name}"
                  c.building = state.tool.building
                  utils.init_building c
                  return {build_ui: true}
        )
      }

  for i=1,constants.num_cols
    for j=1,constants.num_rows
      idx = utils.ij_to_index i, j
      if c = state.map.cells[idx]
        obj = {
          :i, :j
          loc: "map"
          building: c.building
          protected: c.protected
        }
        if c.road
          obj.road_icon = c.road
        if c.building
          obj.icon = c.building.name

        table.insert objects, obj

  -- now do layout
  do
    toolbar_x = 10
    toolbar_y = 10
        
    palette_base_x = constants.screen_w - constants.palette.total_width
    palette_x = constants.palette.initial_x
    palette_y = 100
    palette_n = 0

    for i, obj in ipairs objects
      unless obj
        error("ui object #{i} is nil")

      obj.hover = false

      switch obj.loc
        when "toolbar"
          obj.x = toolbar_x
          obj.y = toolbar_y
          obj.w = 40
          obj.h = 40
          toolbar_x += 50
        when "palette"
          obj.x = palette_x + palette_base_x
          obj.y = palette_y
          obj.w = constants.palette.item_side
          obj.h = constants.palette.item_side

          palette_n += 1
          palette_x += constants.palette.item_side + constants.palette.item_spacing
          if palette_n >= constants.palette.items_per_row
            palette_n = 0
            palette_x = constants.palette.initial_x
            palette_y += constants.palette.item_side + constants.palette.item_spacing_y
        when "map"
          obj.x, obj.y = utils.object_world_pos obj.i, obj.j
          obj.w, obj.h = constants.map.slot_side, constants.map.slot_side
        else
          error "unknown location #{obj.loc}"

  state.ui.objects = objects

build_ui
  