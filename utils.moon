
constants = require "constants"
{:PI} = constants
import mouse, keyboard from require "love"

utils = {}

--------------------------------
-- collisions
--------------------------------

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
utils.check_collision = (x1,y1,w1,h1, x2,y2,w2,h2) ->
  x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1

utils.is_ui_object_hovered = (obj) ->
  x, y = mouse.getPosition!
  utils.check_collision x-2, y-2, 4, 4, obj.x, obj.y, obj.w, obj.h

--------------------------------
-- logging, yay
--------------------------------

utils.log = (s) ->
  io.write "#{s}\n"

--------------------------------
-- input stuff
--------------------------------

utils.is_shift_down = ->
  keyboard.isDown("lshift") or keyboard.isDown("rshift")

--------------------------------
-- map stuff
--------------------------------

utils.init_building = (c) ->
  c.bstate = {}
  if c.building and c.building.inputs and c.building.output
    c.bstate.materials = {}
    for input in *c.building.inputs
      c.bstate.materials[input.name] = 0
    c.bstate.materials[c.building.output.name] = 0

utils.ij_to_index = (i, j) ->
  i + (j-1) * constants.num_cols

utils.obj_ij_diff = (a, b) ->
  return b.i-a.i, b.j-a.j

utils.has_dirs = (c) ->
  return false unless c.dirs
  for k, v in pairs c.dirs
    return true
  false

utils.each_map_index = (f) ->
  for i=1,constants.num_cols
    for j=1,constants.num_rows
      return if f(i, j) == false

utils.object_world_pos = (i, j) ->
  x = constants.map.initial_x + i * constants.map.slot_side
  y = constants.map.initial_y + (j-1) * constants.map.slot_side
  return x, y

utils.is_valid_ij = (i, j) ->
  return false if i < 1
  return false if i > constants.num_cols
  return false if j < 1
  return false if j > constants.num_rows
  true

--------------------------------
-- dir stuff
--------------------------------

Dir = {
  l: {-1, 0},
  r: {1, 0},
  u: {0, -1},
  d: {0, 1},
}
utils.Dir = Dir

utils.dir_to_vec = (d) ->
  switch d
    when Dir.l then {-1, 0}
    when Dir.r then {1, 0}
    when Dir.u then {0, -1}
    when Dir.d then {0, 1}
    else {0, 0}

-- assuming the sprite points up
utils.dir_to_angle = (d) ->
  switch d
    when Dir.l then -PI/2
    when Dir.r then PI/2
    when Dir.d then PI
    when Dir.u then 0
    else 0

feq = (a, b) ->
  math.abs(a-b)<0.1
utils.feq = feq

utils.vec_to_dir = (x, y) ->
  switch true
    when feq(x, -1) and feq(y, 0) then Dir.l
    when feq(x, 1) and feq(y, 0) then Dir.r
    when feq(x, 0) and feq(y, -1) then Dir.u
    when feq(x, 0) and feq(y, 1) then Dir.d
    else nil

utils.dir_opposite = (d) ->
  switch d
    when Dir.l then Dir.r
    when Dir.r then Dir.l
    when Dir.u then Dir.d
    when Dir.d then Dir.u
    else 0

utils.random_dir = ->
  x = love.math.random!
  switch true
    when x < 0.25
      Dir.l
    when x < 0.5
      Dir.r
    when x < 0.75
      Dir.u
    else
      Dir.d

--------------------------------
-- road stuff
--------------------------------

utils.dirs_to_road = (dirs) ->
  name = "road"
  if dirs[Dir.l]
    name = "#{name}-left"
  if dirs[Dir.r]
    name = "#{name}-right"
  if dirs[Dir.u]
    name = "#{name}-up"
  if dirs[Dir.d]
    name = "#{name}-down"
  return name

utils.has_dir = (c, d) ->
  c.dirs and c.dirs[d]

utils.add_dir = (c, d) ->
  changed = not utils.has_dir c, d
  c.dirs or= {}
  c.dirs[d] = true
  changed

utils.remove_dir = (c, d) ->
  changed = utils.has_dir c, d
  c.dirs or= {}
  c.dirs[d] = nil
  changed

-------------------
-- money stuff
-------------------

utils.spend = (state, amount, action) ->
  if state.money > amount
    state.money -= amount
    state.ui.status_text = "just spent $#{amount} to #{action}"
    true
  else
    state.ui.status_text = "can't afford to spend $#{amount} to #{action}"
    false

utils

