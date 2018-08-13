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

  for b in *builtins
    {:i, :j, :building} = b
    idx = utils.ij_to_idx i, j
    c = {
      :i, :j
      :building
      protected: true
    }
    log "built-in #{building.name} at #{i}, #{j}"
    map[idx] = c
  main.build_ui!

love.draw = ->
  draw_ui state
  draw_units state
  draw_mouse state
