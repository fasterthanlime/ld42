
constants = require "constants"

make_state = ->
  state = {}

  state.started_at = nil
  state.money = constants.start_money

  state.map = {
    cells: {}
    units: {}
  }

  state.ui = {
    objects: {}

    cursor: "pointer"
    main_text: ""
    status_text: ""

    building_tab: "infra"
    pressed: false
    hovered: nil
  }

  state.tool = {
    name: "road"
  }

  state.sim = {
    paused: true
    ticks: 0
    step: 0
  }

  state

make_state
