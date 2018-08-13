local graphics, mouse, keyboard, math
do
  local _obj_0 = love
  graphics, mouse, keyboard, math = _obj_0.graphics, _obj_0.mouse, _obj_0.keyboard, _obj_0.math
end
local tween = require("tween")
local pprint = require("pprint")
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
  local _list_0 = state.map.units
  for _index_0 = 1, #_list_0 do
    local u = _list_0[_index_0]
    local d = utils.random_dir()
    local diff_i, diff_j
    do
      local _obj_0 = utils.dir_to_vec(d)
      diff_i, diff_j = _obj_0[1], _obj_0[2]
    end
    u.d = d
    u.angle = utils.dir_to_angle(d)
    u.tween = tween.new(constants.step_duration, u, {
      i = u.i + diff_i,
      j = u.j + diff_j
    })
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
