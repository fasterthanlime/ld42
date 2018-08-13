-- auto-refresh
lick = require "lick"
lick.reset = true -- reload game every time it's compiled

-- love2d
import graphics, mouse, keyboard, math from love

-- external modules
tween = require "tween"

-- our own modules
constants = require "constants"
utils = require "utils"
{:log, :Dir} = utils
state = require "state"
imgs = require "imgs"
buildings = require "buildings"
units = require "units"

-- important functions
draw_roads = require "draw_roads"
build_ui = require "build_ui"

main = {}

main.do_step = ->
  state.sim.step += 1

  log "stepping!"
  for u in *state.map.units
    d = utils.random_dir!
    {diff_i, diff_j} = utils.dir_to_vec d
    u.d = d
    u.angle = utils.dir_to_angle d
    u.tween = tween.new constants.step_duration, u, {
      i: u.i + diff_i,
      j: u.j + diff_j,
    }

main.update_ui = ->
  -- find hovered objects
  old_hover = state.ui.hovered
  state.ui.hovered = nil
  for obj in *state.ui.objects
    if obj.hover = utils.is_ui_object_hovered obj
      state.ui.hovered = obj

  if state.ui.hovered
    state.ui.cursor = "hand"
  else
    state.ui.cursor = "pointer"

  -- draw roads if necessary
  if draw_roads state, old_hover, new_hover
    main.autotile_roads!

  state.ui.status_text = "started #{startedAt.hour}:#{startedAt.min}:#{startedAt.sec} | step #{stepIndex} | money $#{money}"

main.update_sim = (dt) ->
  state.sim.ticks += dt
  if state.sim.ticks > constants.step_duration
    state.sim.ticks -= constants.step_duration
    main.do_step!

  for u in *state.map.units
    if u.tween
      if u.tween\update dt
        u.tween = nil

love.update = (dt) ->
  unless paused
    main.update_sim dt
  main.update_ui!

love.mousepressed = (x, y, button, istouch, presses) ->
  state.ui.pressed = true 

  if state.ui.hovered and state.ui.hovered.onclick
    if ret = state.ui.hovered.onclick state
      if ret.build_ui
        main.build_ui!
      if ret.autotile_roads!
        main.autotile_roads!

love.mousereleased = (x, y, button, istouch, presses) ->
  state.ui.pressed = false

local standardButtons

main.build_ui = ->
  build_ui state

-- picks the right sprite to display for roads
main.autotile_roads = ->
  utils.each_map_index (i, j) ->
    if c = map[i+(j-1)*num_cols]
      if c.road and c.dirs
        c.road = dirs_to_road c.dirs
  main.build_ui!

love.load = ->
  -- works around stdout not flushing on windows
  io.stdout\setvbuf "no"

  -- we have our own pointer
  mouse.setVisible false

  startedAt = os.date '*t' 

  for i=1,num_cols*num_rows
    map[i] = {}

  builtins = {
    {i: 3, j: 4, building: findBuilding("terrain", "city")}

    ----

    {i: 5, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 5, j: 4, building: findBuilding("terrain", "mountains")}
    {i: 5, j: 5, building: findBuilding("terrain", "mountains")}

    {i: 6, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 6, j: 4, building: findBuilding("terrain", "mountains")}
    {i: 6, j: 5, building: findBuilding("terrain", "mountains")}

    {i: 7, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 7, j: 4, building: findBuilding("terrain", "mountains")}

    ----

    {i: 9, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 9, j: 4, building: findBuilding("terrain", "mountains")}

    {i: 10, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 10, j: 4, building: findBuilding("terrain", "mountains")}

    {i: 11, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 11, j: 4, building: findBuilding("terrain", "mountains")}

    {i: 12, j: 3, building: findBuilding("terrain", "mountains")}
    {i: 12, j: 4, building: findBuilding("terrain", "mountains")}
    {i: 12, j: 5, building: findBuilding("terrain", "mountains")}

    {i: 10, j: 2, building: findBuilding("mine", "diamond")}
    {i: 10, j: 7, building: findBuilding("mine", "gold")}
  }

  for b in *builtins
    {:i, :j, :building} = b
    idx = i+(j-1)*num_cols
    c = {
      :i, :j
      :building
      protected: true
    }
    log "built-in #{building.name} at #{i}, #{j}"
    map[idx] = c
  buildRoads!

  buildUI!

drawFG = ->
  nil -- muffin

drawUI = ->
  graphics.reset!
  graphics.setColor 1, 1, 1
  -- graphics.setFont font
  graphics.print text, 20, screenHeight-30

  do 
    for obj in *uiObjects
      graphics.reset!
      if obj.hover and not obj.protected and obj.loc != "map"
        graphics.setColor 0.8, 0.8, 1.0
      else
        graphics.setColor 1, 1, 1
      {:x, :y} = obj

      scale = 1
      angle = 0

      switch obj.loc 
        when "palette"
          scale = 0.75
          angle = obj.hover and 0 or 3.14 * 1/64

      switch obj.loc 
        when "toolbar"
          graphics.draw images.buttonExtras.bg, x, y, angle, scale, scale
      if icon = obj.icon
        -- if obj.loc == "map" and not obj.meta
        --   graphics.draw images.buildings.bg, x, y, angle, scale, scale
        graphics.draw icon, x, y, angle, scale, scale
      else if icon = obj.roadIcon
        graphics.draw icon, x, y, angle, scale, scale

drawUnits = ->
  graphics.reset!

  for u in *mapUnits
    {:i, :j, :d, :angle} = u
    x, y = object_world_pos i, j
    unitHalf = unitSide/2
    ox, oy = unitHalf, unitHalf

    slotHalf = slotSide/2
    x += slotHalf
    y += slotHalf
    scale = 1
    img = images.units[u.unit.name]
    graphics.draw img, x, y, angle, scale, scale, ox, oy

drawMouse = ->
  x, y = mouse.getPosition!
  graphics.reset!
  img = images.cursors[currentCursor]
  graphics.draw img, x, y

  do
    img = nil
    switch currentTool
      when "building"
        if currentBuilding
          img = images.buildings[currentBuilding.name]
      when "unit"
        if currentUnit
          img = images.units[currentUnit.name]
      when "road"
        img = images.roads["road-left-right"]

    if img
      scale = 0.5
      x += 16
      y += 16
      if isShiftDown!
        graphics.setColor 1.0, 0.6, 0.6, 1
      else
        graphics.setColor 0.6, 1.0, 0.6, 1
      graphics.draw img, x, y, 0, scale, scale

love.draw = ->
  drawFG!
  drawUI!
  drawUnits!
  drawMouse!

newImage = (path) ->
  img = graphics.newImage path
  unless img
    error("image not found: #{img}")
  log "loaded #{path}"
  img
