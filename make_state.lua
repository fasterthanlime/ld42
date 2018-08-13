local constants = require("constants")
local make_state
make_state = function()
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
    main_text = "",
    status_text = "",
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
end
return make_state
