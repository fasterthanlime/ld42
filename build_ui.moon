
utils = require "utils"
constants = require "constants"
{:log, :Dir} = utils

standard_buttons = {
  pause: {
    loc: "toolbar"
    icon: "pause"
    onclick: ((state) ->
      state.paused = true
      return {build_ui: true}
    )
  }
  play: {
    loc: "pause"
    icon: "play"
    onclick: ((state) ->
      state.paused = false
      return {build_ui: true}
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

  if paused
    table.insert objects, standard_buttons.play
  else
    table.insert objects, standard_buttons.pause

  do
    obj = {
      loc: "palette"
      icon: "road-left-right"
      onclick: ((state)->
        state.ui.tool = {name: "road"}
      )
    }
    table.insert objects, obj

  for b in *(buildings[buildingTab])
    obj = {
      loc: "palette"
      icon: b.name
      onclick: ((state) ->
        state.ui.tool = {name: "building", building: b}
      )
    }
    unless obj.icon 
      error("could not find icon for building #{b}")
    table.insert objects, obj

  for u in *units
    obj = {
      loc: "palette"
      icon: u.name
      onclick: ((state) ->
        state.ui.tool = {name: "unit", unit: u}
      )
    }
    table.insert objects, obj

  for i=1,num_cols
    for j=1,num_rows
      table.insert objects, {
        :i, :j
        loc: "map"
        meta: true
        icon: "slot"
        onclick: ((state) ->
          switch state.tool.name
            when "road"
              nil -- muffin
            when "unit"
              if state.tool.unit
                table.insert state.map.units, {
                  :i, :j
                  d: Dir.u
                  angle: 0
                  unit: state.tool.unit
                }
            when "building"
              ids = utils.ij_to_idx i, j
              if map[idx] and map[idx].protected
                return
              if utils.is_shift_down!
                map[idx].building = nil
                return {build_ui: true}
              else
                map[idx] or= {}
                map[idx].building = state.tool.building
                return {build_ui: true}
        )
      }

  for i=1,num_cols
    for j=1,num_rows
      if c = map[i+(j-1)*num_cols]
        obj = {
          :i, :j
          loc: "map"
          building: c.building
          protected: c.protected
        }
        if c.road
          obj.road_icon = images.roads[c.road]
        if c.building
          obj.icon = images.buildings[c.building.name]

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
          palette_x += constants.palette.item_side + paletteItemSpacing
          if palette_n >= paletteItemsPerRow
            palette_n = 0
            palette_x = constants.palette.initial_x
            palette_y += constants.palette.item_side + paletteItemSpacing
        when "map"
          obj.x, obj.y = utils.object_world_pos obj.i, obj.j
          obj.w, obj.h = constants.map.slot_side, constants.map.slot_side
        else
          error "unknown location #{obj.loc}"

  state.ui.objects = objects
  