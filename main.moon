-- love2d
import graphics, mouse, keyboard from love

-- external modules
tween = require "tween"
pprint = require "pprint"
astar = require "astar"

-- our own modules
constants = require "constants"
utils = require "utils"
{:log, :Dir} = utils
make_state = require "make_state"
imgs = require "imgs"
buildings = require "buildings"
units = require "units"
materials = require "materials"
builtins = require "builtins"

-- important functions
draw_roads = require "draw_roads"
build_ui = require "build_ui"
draw_ui = require "draw_ui"
draw_units = require "draw_units"
draw_mouse = require "draw_mouse"

-- globals!
state = nil
main = {}

main.do_step = ->
  state.sim.step += 1

  -- step buildings
  for i=1,constants.num_cols
    for j=1,constants.num_rows
      idx = utils.ij_to_index i, j
      c = state.map.cells[idx]
      if b = c.building
        has_all_material = true
        continue unless b.inputs and b.output
        outname = b.output.name

        if c.bstate.materials[outname] > constants.max_output
          continue

        for input in *b.inputs
          if c.bstate.materials[input.name] < input.amount
            has_all_material = false
        if has_all_material
          for input in *b.inputs
            c.bstate.materials[input.name] -= input.amount
          c.bstate.materials[outname] += b.output.amount

          if #b.inputs > 0
            log "producing #{b.output.amount} #{outname} at #{i}, #{j}"
            pprint c.bstate.materials
            log "-------------"

  -- step vehicles
  all_nodes = {}
  for i=1,constants.num_cols
    for j=1,constants.num_rows
      idx = utils.ij_to_index i, j
      c = state.map.cells[idx]
      if utils.has_dirs c
        table.insert all_nodes, {
          x: i,
          y: j
          :i, :j
          c: c
        }
  -- log "got #{#all_nodes} nodes total"

  valid_node_func = (node, neighbor) ->
    i, j = utils.obj_ij_diff node, neighbor
    d = utils.vec_to_dir(i, j)
    return false if d == nil
    return utils.has_dir node.c, d

  neighbor_nodes = (node) ->
    neighbors = {}

    while true
      old_neighbors = neighbors
      neighbors = {}
      add_neighbor = (n) ->
        if n == node
          return
        for nn in *neighbors
          if nn == n
            return
        table.insert neighbors, n
      
      visit_node = (on) ->
        for n in *all_nodes
          if valid_node_func on, n
            add_neighbor n

      visit_node node
      for on in *old_neighbors
        visit_node on
      
      if #neighbors == #old_neighbors
        return neighbors

  for u_index, u in ipairs state.map.units
    if u.path
      u.path.index += 1
      if u.path.index > #u.path.nodes
        -- log "completed path!"
        last_node = u.path.nodes[u.path.index-1]

        -- log "last node was: "
        -- pprint last_node

        c = last_node.c
        if b = c.building
          switch b.name
            when "city"
              -- log "we're in the city! do we got anything to sell?"
              for k, v in pairs u.materials
                if v > 0
                  -- log "let's sell #{k}"
                  profit = materials[k].price * v
                  -- log "...for $#{profit}"
                  u.materials[k] = 0
                  state.money += profit
            else if b.inputs and b.output
              outname = b.output.name

              for input in *b.inputs
                avail = u.materials[input.name] or 0
                if avail > 0
                  log "depositing #{avail} #{input.name} to #{b.name}"
                  c.bstate.materials[input.name] += avail
                  u.materials[input.name] -= avail

              u.materials[outname] or= 0
              merch_avail = c.bstate.materials[outname]
              space_taken = 0
              for k, v in pairs u.materials
                space_taken += v
              space_avail = u.unit.capacity - space_taken
              merch_taken = math.min(space_avail, merch_avail)

              if merch_taken > 0
                log "grabbing #{merch_taken} #{outname} from #{b.name}"
                u.materials[outname] += merch_taken
                c.bstate.materials[outname] -= merch_taken

        u.path = nil

    unless u.path
      start = nil
      for n in *all_nodes
        if n.i == u.i and n.j == u.j
          start = n
          break

      unless start
        -- log "cannot move vehicle #{u_index} (not on the road)"
        continue

      neighbors = neighbor_nodes start
      if #neighbors == 0
        -- log "cannot move vehicle #{u_index} (no neighbors)"
        continue
      -- log "found #{#neighbors} neighbors"

      building_neighbors = {}
      for n in *neighbors
        if n.c.building
          table.insert building_neighbors, n
      neighbors = building_neighbors
      -- log "found #{#neighbors} building neighbors"

      if utils.unit_is_full u
        -- log "unit is full, trying to eliminate bad neighbors"
        good_neighbors = {}
        for n in *neighbors
          if utils.unit_has_input_for_cell u, n.c
            table.insert good_neighbors, n
        -- log "narrowed it down #{#neighbors} -> #{#good_neighbors}"
        neighbors = good_neighbors

      if #neighbors == 0
        -- log "cannot move vehicle #{u_index} (no good neighbors)"
        continue

      goal = neighbors[love.math.random(#neighbors)]
      -- log "picked goal: "
      -- pprint goal

      if nodes = astar.path start, goal, all_nodes, ignore, valid_node_func
        -- log "found path with #{#nodes} nodes! setting..."
        u.path = {
          :nodes
          index: 1
        }
      else
        -- log "cannot move vehicle #{u_index} (could not find path from)"
        -- pprint start
        -- log "to: "
        -- pprint goal
        continue

    if u.path
      node = u.path.nodes[u.path.index]
      diff_i = node.i - u.i
      diff_j = node.j - u.j
      d = utils.vec_to_dir diff_i, diff_j
      u.d = d
      u.angle = utils.dir_to_angle d
      u.tween = tween.new constants.step_duration, u, {
        i: node.i
        j: node.j
      }

main.update_ui = ->
  -- find hovered objects
  old_hover = state.ui.hovered
  state.ui.hovered = nil
  for obj in *state.ui.objects
    obj.hover = utils.is_ui_object_hovered obj
    if obj.hover and not state.ui.hovered
      state.ui.hovered = obj

  if state.ui.hovered
    state.ui.cursor = "hand"
  else
    state.ui.cursor = "pointer"

  -- draw roads if necessary
  new_hover = state.ui.hovered
  if draw_roads state, old_hover, new_hover
    log ">>>>>> auto-tiling roads!"
    main.autotile_roads!

  start = state.started_at
  state.ui.main_text = "started #{start.hour}:#{start.min}:#{start.sec} | step #{state.sim.step} | money $#{state.money}"

main.update_sim = (dt) ->
  state.sim.ticks += dt
  if state.sim.ticks > constants.step_duration
    state.sim.ticks -= constants.step_duration
    main.do_step!

  for u in *state.map.units
    if u.tween
      if u.tween\update dt
        u.tween = nil
        u.i = math.floor u.i
        u.j = math.floor u.j

love.update = (dt) ->
  unless state.sim.paused
    main.update_sim dt
  main.update_ui!

love.mousepressed = (x, y, button, istouch, presses) ->
  state.ui.pressed = true 

  if he = state.ui.hovered
    if he.onclick
      if ret = he.onclick state
        if ret.build_ui
          log "rebuilding ui after onclick"
          main.build_ui!
        if ret.autotile_roads
          log "autotiling roads after onclick"
          main.autotile_roads!
        if ret.restart
          log "restarting after onclick"
          main.start!

love.mousereleased = (x, y, button, istouch, presses) ->
  state.ui.pressed = false

main.build_ui = ->
  build_ui state

-- picks the right sprite to display for roads
main.autotile_roads = ->
  utils.each_map_index (i, j) ->
    idx = utils.ij_to_index i, j
    if c = state.map.cells[idx]
      if c.dirs
        c.road = utils.dirs_to_road c.dirs
  main.build_ui!

love.load = ->
  -- works around stdout not flushing on windows
  io.stdout\setvbuf "no"

  -- we have our own pointer
  mouse.setVisible false

  imgs.load_all!

  main.start!

main.start = ->
  state = make_state!
  state.started_at = os.date '*t' 

  utils.each_map_index (i, j) ->
    log "preparing cell at #{i}, #{j}"
    idx = utils.ij_to_index i, j
    state.map.cells[idx] = {}

  for b in *builtins
    {:i, :j, :building} = b
    idx = utils.ij_to_index i, j
    c = {
      :i, :j
      :building
      protected: true
    }
    log "built-in #{building.name} at #{i}, #{j}"
    utils.init_building c
    state.map.cells[idx] = c
  main.build_ui!

love.draw = ->
  draw_ui state
  draw_units state
  draw_mouse state
