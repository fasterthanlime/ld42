local graphics
graphics = require("love").graphics
local imgs = { }
imgs.images = { }
local to_load = {
  {
    "cursors",
    "pointer"
  },
  {
    "cursors",
    "hand"
  },
  {
    "buildings",
    "building-bg"
  },
  {
    "buildings",
    "cinema"
  },
  {
    "buildings",
    "city"
  },
  {
    "buildings",
    "copper"
  },
  {
    "buildings",
    "cross"
  },
  {
    "buildings",
    "depot"
  },
  {
    "buildings",
    "diamond"
  },
  {
    "buildings",
    "gold"
  },
  {
    "buildings",
    "jewelry"
  },
  {
    "buildings",
    "library"
  },
  {
    "buildings",
    "microchips"
  },
  {
    "buildings",
    "mountains"
  },
  {
    "buildings",
    "oil"
  },
  {
    "buildings",
    "plastic"
  },
  {
    "buildings",
    "power-plant"
  },
  {
    "buildings",
    "toys"
  },
  {
    "buildings",
    "tree"
  },
  {
    "buildings",
    "wires"
  },
  {
    "buttons",
    "restart"
  },
  {
    "buttons",
    "button-bg"
  },
  {
    "buttons",
    "pause"
  },
  {
    "buttons",
    "play"
  },
  {
    "buttons",
    "slot"
  },
  {
    "buttons",
    "toolbar"
  },
  {
    "buttons",
    "clear-units"
  },
  {
    "misc",
    "arrow"
  },
  {
    "roads",
    "road"
  },
  {
    "roads",
    "road-down"
  },
  {
    "roads",
    "road-left"
  },
  {
    "roads",
    "road-left-down"
  },
  {
    "roads",
    "road-left-right"
  },
  {
    "roads",
    "road-left-right-down"
  },
  {
    "roads",
    "road-left-right-up"
  },
  {
    "roads",
    "road-left-right-up-down"
  },
  {
    "roads",
    "road-left-up"
  },
  {
    "roads",
    "road-left-up-down"
  },
  {
    "roads",
    "road-right"
  },
  {
    "roads",
    "road-right-down"
  },
  {
    "roads",
    "road-right-up"
  },
  {
    "roads",
    "road-right-up-down"
  },
  {
    "roads",
    "road-up"
  },
  {
    "roads",
    "road-up-down"
  },
  {
    "units",
    "jeep"
  },
  {
    "units",
    "van"
  },
  {
    "units",
    "truck"
  }
}
imgs.get = function(name)
  local img = imgs.images[name]
  if not (img) then
    error("image not found: " .. tostring(name))
  end
  return img
end
imgs.load_all = function(name)
  for _index_0 = 1, #to_load do
    local t = to_load[_index_0]
    local dir
    dir, name = t[1], t[2]
    local path = "art/" .. tostring(dir) .. "/" .. tostring(name) .. ".png"
    local img = graphics.newImage(path)
    if not (img) then
      error("image not found: " .. tostring(img))
    end
    imgs.images[name] = img
  end
end
return imgs
