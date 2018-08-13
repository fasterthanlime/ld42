
constants = {}

------------------
-- dimensions
------------------
constants.screen_w = 1200
constants.screen_h = 700
constants.num_cols = 14
constants.num_rows = 9

constants.palette = do
  p = {
    initial_x: 10
    items_per_row: 3
    item_side: 40
    item_spacing: 25
    item_spacing_y: 60
  }
  p.total_width = p.initial_x + (p.item_side + p.item_spacing) * p.items_per_row + 30
  p

constants.map = {
  initial_x: 0
  initial_y: 60
  slot_side: 60
  unit_side: 30
}

---------------------------
-- time variables
---------------------------
constants.step_duration = 0.2

constants.max_units = 100

------------------
-- costs
------------------

-- constants.start_money = 12000
constants.start_money = 30000
constants.road_cost = 5000
constants.max_output = 5000
constants.max_input = 10000

constants.small_font = love.graphics.newFont 10
constants.big_font = love.graphics.newFont 24

-------------------
-- maths
-------------------

constants.PI = 3.14159265 -- that's all I can remember tonight

constants
