local constants = require("constants")
local PI
PI = constants.PI
local mouse, keyboard
do
  local _obj_0 = require("love")
  mouse, keyboard = _obj_0.mouse, _obj_0.keyboard
end
local utils = { }
local feq
feq = function(a, b)
  return math.abs(a - b) < 0.1
end
utils.feq = feq
utils.check_collision = function(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end
utils.is_ui_object_hovered = function(obj)
  local x, y = mouse.getPosition()
  return utils.check_collision(x - 2, y - 2, 4, 4, obj.x, obj.y, obj.w, obj.h)
end
utils.log = function(s)
  return io.write(tostring(s) .. "\n")
end
utils.is_shift_down = function()
  return keyboard.isDown("lshift") or keyboard.isDown("rshift")
end
utils.unit_taken_space = function(u)
  local taken_space = 0
  for k, v in pairs(u.materials) do
    taken_space = taken_space + v
  end
  return taken_space
end
utils.unit_avail_space = function(u)
  return u.unit.capacity - utils.unit_taken_space(u)
end
utils.unit_is_full = function(u)
  return feq(utils.unit_avail_space(u), 0)
end
utils.unit_has_input_for_cell = function(u, c)
  local b = c.building
  if b.name == "city" then
    return true
  end
  if b.inputs and b.output then
    local _list_0 = b.inputs
    for _index_0 = 1, #_list_0 do
      local input = _list_0[_index_0]
      local material_avail = u.materials[input.name] or 0
      if material_avail > 0 then
        return true
      end
    end
  end
  return false
end
utils.init_building = function(c)
  c.bstate = { }
  if c.building and c.building.inputs and c.building.output then
    c.bstate.materials = { }
    local _list_0 = c.building.inputs
    for _index_0 = 1, #_list_0 do
      local input = _list_0[_index_0]
      c.bstate.materials[input.name] = 0
    end
    c.bstate.materials[c.building.output.name] = 0
  end
end
utils.ij_to_index = function(i, j)
  return i + (j - 1) * constants.num_cols
end
utils.obj_ij_diff = function(a, b)
  return b.i - a.i, b.j - a.j
end
utils.has_dirs = function(c)
  if not (c.dirs) then
    return false
  end
  for k, v in pairs(c.dirs) do
    return true
  end
  return false
end
utils.each_map_index = function(f)
  for i = 1, constants.num_cols do
    for j = 1, constants.num_rows do
      if f(i, j) == false then
        return 
      end
    end
  end
end
utils.object_world_pos = function(i, j)
  local x = constants.map.initial_x + i * constants.map.slot_side
  local y = constants.map.initial_y + (j - 1) * constants.map.slot_side
  return x, y
end
utils.is_valid_ij = function(i, j)
  if i < 1 then
    return false
  end
  if i > constants.num_cols then
    return false
  end
  if j < 1 then
    return false
  end
  if j > constants.num_rows then
    return false
  end
  return true
end
local Dir = {
  l = {
    -1,
    0
  },
  r = {
    1,
    0
  },
  u = {
    0,
    -1
  },
  d = {
    0,
    1
  }
}
utils.Dir = Dir
utils.dir_to_vec = function(d)
  local _exp_0 = d
  if Dir.l == _exp_0 then
    return {
      -1,
      0
    }
  elseif Dir.r == _exp_0 then
    return {
      1,
      0
    }
  elseif Dir.u == _exp_0 then
    return {
      0,
      -1
    }
  elseif Dir.d == _exp_0 then
    return {
      0,
      1
    }
  else
    return {
      0,
      0
    }
  end
end
utils.dir_to_angle = function(d)
  local _exp_0 = d
  if Dir.l == _exp_0 then
    return -PI / 2
  elseif Dir.r == _exp_0 then
    return PI / 2
  elseif Dir.d == _exp_0 then
    return PI
  elseif Dir.u == _exp_0 then
    return 0
  else
    return 0
  end
end
utils.vec_to_dir = function(x, y)
  local _exp_0 = true
  if (feq(x, -1) and feq(y, 0)) == _exp_0 then
    return Dir.l
  elseif (feq(x, 1) and feq(y, 0)) == _exp_0 then
    return Dir.r
  elseif (feq(x, 0) and feq(y, -1)) == _exp_0 then
    return Dir.u
  elseif (feq(x, 0) and feq(y, 1)) == _exp_0 then
    return Dir.d
  else
    return nil
  end
end
utils.dir_opposite = function(d)
  local _exp_0 = d
  if Dir.l == _exp_0 then
    return Dir.r
  elseif Dir.r == _exp_0 then
    return Dir.l
  elseif Dir.u == _exp_0 then
    return Dir.d
  elseif Dir.d == _exp_0 then
    return Dir.u
  else
    return 0
  end
end
utils.random_dir = function()
  local x = love.math.random()
  local _exp_0 = true
  if (x < 0.25) == _exp_0 then
    return Dir.l
  elseif (x < 0.5) == _exp_0 then
    return Dir.r
  elseif (x < 0.75) == _exp_0 then
    return Dir.u
  else
    return Dir.d
  end
end
utils.dirs_to_road = function(dirs)
  local name = "road"
  if dirs[Dir.l] then
    name = tostring(name) .. "-left"
  end
  if dirs[Dir.r] then
    name = tostring(name) .. "-right"
  end
  if dirs[Dir.u] then
    name = tostring(name) .. "-up"
  end
  if dirs[Dir.d] then
    name = tostring(name) .. "-down"
  end
  return name
end
utils.has_dir = function(c, d)
  return c.dirs and c.dirs[d]
end
utils.add_dir = function(c, d)
  local changed = not utils.has_dir(c, d)
  c.dirs = c.dirs or { }
  c.dirs[d] = true
  return changed
end
utils.remove_dir = function(c, d)
  local changed = utils.has_dir(c, d)
  c.dirs = c.dirs or { }
  c.dirs[d] = nil
  return changed
end
utils.spend = function(state, amount, action)
  if state.money >= amount then
    state.money = state.money - amount
    state.ui.status_text = "just spent " .. tostring(utils.format_price(amount)) .. " to " .. tostring(action)
    return true
  else
    state.ui.status_text = "can't afford to spend " .. tostring(utils.format_price(amount)) .. " to " .. tostring(action)
    return false
  end
end
utils.format_price = function(p)
  if p > 1000 then
    local thousands = p / 1000
    return "$" .. tostring(utils.round(thousands, 2)) .. "K"
  end
  return "$" .. tostring(p)
end
utils.round = function(num, numDecimalPlaces)
  local mult = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
return utils
