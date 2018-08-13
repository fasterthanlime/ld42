local constants = require("constants")
local state = { }
state.started_at = nil
state.money = constants.start_money
state.map = {
  cells = { },
  units = { }
}
state.ui = {
  objects = { },
  cursor = "pointer",
  status_text = "hello there",
  building_tab = "infra",
  pressed = false,
  hovered = nil
}
state.tool = {
  name = "road"
}
state.sim = {
  paused = true,
  ticks = 0,
  step = 0
}
return state
