local graphics, mouse, keyboard
do
  local _obj_0 = love
  graphics, mouse, keyboard = _obj_0.graphics, _obj_0.mouse, _obj_0.keyboard
end
local tween = require("tween")
local pprint = require("pprint")
local astar = require("astar")
local constants = require("constants")
local utils = require("utils")
local log, Dir
log, Dir = utils.log, utils.Dir
local make_state = require("make_state")
local imgs = require("imgs")
local buildings = require("buildings")
local units = require("units")
local builtins = require("builtins")
local draw_roads = require("draw_roads")
local build_ui = require("build_ui")
local draw_ui = require("draw_ui")
local draw_units = require("draw_units")
local draw_mouse = require("draw_mouse")
local state = nil
local main = { }
main.do_step = function()
  state.sim.step = state.sim.step + 1
  log("stepping!")
  local all_nodes = { }
  for i = 1, constants.num_cols do
    for j = 1, constants.num_rows do
      local idx = utils.ij_to_index(i, j)
      local c = state.map.cells[idx]
      if utils.has_dirs(c) then
        table.insert(all_nodes, {
          x = i,
          y = j,
          i = i,
          j = j,
          c = c
        })
      end
    end
  end
  log("got " .. tostring(#all_nodes) .. " nodes total")
  local valid_node_func
  valid_node_func = function(node, neighbor)
    local i, j = utils.obj_ij_diff(node, neighbor)
    local d = utils.vec_to_dir(i, j)
    if d == nil then
      return false
    end
    return utils.has_dir(node.c, d)
  end
  local neighbor_nodes
  neighbor_nodes = function(node)
    local neighbors = { }
    while true do
      local old_neighbors = neighbors
      neighbors = { }
      local add_neighbor
      add_neighbor = function(n)
        if n == node then
          return 
        end
        for _index_0 = 1, #neighbors do
          local nn = neighbors[_index_0]
          if nn == n then
            return 
          end
        end
        return table.insert(neighbors, n)
      end
      local visit_node
      visit_node = function(on)
        for _index_0 = 1, #all_nodes do
          local n = all_nodes[_index_0]
          if valid_node_func(on, n) then
            add_neighbor(n)
          end
        end
      end
      visit_node(node)
      for _index_0 = 1, #old_neighbors do
        local on = old_neighbors[_index_0]
        visit_node(on)
      end
      if #neighbors == #old_neighbors then
        return neighbors
      end
    end
  end
  for u_index, u in ipairs(state.map.units) do
    local _continue_0 = false
    repeat
      if u.path then
        u.path.index = u.path.index + 1
        if u.path.index > #u.path.nodes then
          log("completed path!")
          u.path = nil
        end
      end
      if not (u.path) then
        local start = nil
        for _index_0 = 1, #all_nodes do
          local n = all_nodes[_index_0]
          if n.i == u.i and n.j == u.j then
            start = n
            break
          end
        end
        if not (start) then
          log("cannot move vehicle " .. tostring(u_index) .. " (not on the road)")
          _continue_0 = true
          break
        end
        local neighbors = neighbor_nodes(start)
        if #neighbors == 0 then
          log("cannot move vehicle " .. tostring(u_index) .. " (no neighbors)")
          _continue_0 = true
          break
        end
        log("found " .. tostring(#neighbors) .. " neighbors")
        local building_neighbors = { }
        for _index_0 = 1, #neighbors do
          local n = neighbors[_index_0]
          if n.c.building then
            table.insert(building_neighbors, n)
          end
        end
        neighbors = building_neighbors
        log("found " .. tostring(#neighbors) .. " building neighbors")
        if #neighbors == 0 then
          log("cannot move vehicle " .. tostring(u_index) .. " (no building neighbors)")
          _continue_0 = true
          break
        end
        local goal = neighbors[love.math.random(#neighbors)]
        log("picked goal: ")
        pprint(goal)
        do
          local nodes = astar.path(start, goal, all_nodes, ignore, valid_node_func)
          if nodes then
            log("found path with " .. tostring(#nodes) .. " nodes! setting...")
            u.path = {
              nodes = nodes,
              index = 1
            }
          else
            log("cannot move vehicle " .. tostring(u_index) .. " (could not find path from)")
            pprint(start)
            log("to: ")
            pprint(goal)
            _continue_0 = true
            break
          end
        end
      end
      if u.path then
        local node = u.path.nodes[u.path.index]
        local diff_i = node.i - u.i
        local diff_j = node.j - u.j
        log("diff = " .. tostring(diff_i) .. ", " .. tostring(diff_j))
        local d = utils.vec_to_dir(diff_i, diff_j)
        pprint(d)
        u.d = d
        u.angle = utils.dir_to_angle(d)
        u.tween = tween.new(constants.step_duration, u, {
          i = node.i,
          j = node.j
        })
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end
main.update_ui = function()
  local old_hover = state.ui.hovered
  state.ui.hovered = nil
  local _list_0 = state.ui.objects
  for _index_0 = 1, #_list_0 do
    local obj = _list_0[_index_0]
    obj.hover = utils.is_ui_object_hovered(obj)
    if obj.hover and not state.ui.hovered then
      state.ui.hovered = obj
    end
  end
  if state.ui.hovered then
    state.ui.cursor = "hand"
  else
    state.ui.cursor = "pointer"
  end
  local new_hover = state.ui.hovered
  if draw_roads(state, old_hover, new_hover) then
    log(">>>>>> auto-tiling roads!")
    main.autotile_roads()
  end
  local start = state.started_at
  state.ui.main_text = "started " .. tostring(start.hour) .. ":" .. tostring(start.min) .. ":" .. tostring(start.sec) .. " | step " .. tostring(state.sim.step) .. " | money $" .. tostring(state.money)
end
main.update_sim = function(dt)
  state.sim.ticks = state.sim.ticks + dt
  if state.sim.ticks > constants.step_duration then
    state.sim.ticks = state.sim.ticks - constants.step_duration
    main.do_step()
  end
  local _list_0 = state.map.units
  for _index_0 = 1, #_list_0 do
    local u = _list_0[_index_0]
    if u.tween then
      if u.tween:update(dt) then
        u.tween = nil
        u.i = math.floor(u.i)
        u.j = math.floor(u.j)
      end
    end
  end
end
love.update = function(dt)
  if not (state.sim.paused) then
    main.update_sim(dt)
  end
  return main.update_ui()
end
love.mousepressed = function(x, y, button, istouch, presses)
  state.ui.pressed = true
  do
    local he = state.ui.hovered
    if he then
      if he.onclick then
        do
          local ret = he.onclick(state)
          if ret then
            if ret.build_ui then
              log("rebuilding ui after onclick")
              main.build_ui()
            end
            if ret.autotile_roads then
              log("autotiling roads after onclick")
              main.autotile_roads()
            end
            if ret.restart then
              log("restarting after onclick")
              return main.start()
            end
          end
        end
      end
    end
  end
end
love.mousereleased = function(x, y, button, istouch, presses)
  state.ui.pressed = false
end
main.build_ui = function()
  return build_ui(state)
end
main.autotile_roads = function()
  utils.each_map_index(function(i, j)
    local idx = utils.ij_to_index(i, j)
    do
      local c = state.map.cells[idx]
      if c then
        if c.dirs then
          c.road = utils.dirs_to_road(c.dirs)
        end
      end
    end
  end)
  return main.build_ui()
end
love.load = function()
  io.stdout:setvbuf("no")
  mouse.setVisible(false)
  imgs.load_all()
  return main.start()
end
main.start = function()
  state = make_state()
  state.started_at = os.date('*t')
  utils.each_map_index(function(i, j)
    log("preparing cell at " .. tostring(i) .. ", " .. tostring(j))
    local idx = utils.ij_to_index(i, j)
    state.map.cells[idx] = { }
  end)
  for _index_0 = 1, #builtins do
    local b = builtins[_index_0]
    local i, j, building
    i, j, building = b.i, b.j, b.building
    local idx = utils.ij_to_index(i, j)
    local c = {
      i = i,
      j = j,
      building = building,
      protected = true
    }
    log("built-in " .. tostring(building.name) .. " at " .. tostring(i) .. ", " .. tostring(j))
    state.map.cells[idx] = c
  end
  return main.build_ui()
end
love.draw = function()
  draw_ui(state)
  draw_units(state)
  return draw_mouse(state)
end
