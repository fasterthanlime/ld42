local constants = { }
constants.screen_w = 1200
constants.screen_h = 700
constants.num_cols = 14
constants.num_rows = 9
do
  local p = {
    initial_x = 10,
    items_per_row = 4,
    item_side = 40,
    item_spacing = 15
  }
  p.total_width = p.initial_x + (p.item_side + p.item_spacing) * p.items_per_row + 30
  constants.palette = p
end
constants.map = {
  initial_x = 0,
  initial_y = 60,
  slot_side = 60,
  unit_side = 30
}
constants.step_duration = .5
constants.start_money = 2000
constants.road_cost = 150
constants.destruction_cost = 300
constants.PI = 3.14159265
return constants
