
import graphics from require "love"

imgs = {}

imgs.images = {}

to_load = {
  {"cursors", "pointer"}
  {"cursors", "hand"}

  {"buildings", "building-bg"}
  {"buildings", "cinema"}
  {"buildings", "city"}
  {"buildings", "copper"}
  {"buildings", "cross"}
  {"buildings", "depot"}
  {"buildings", "diamond"}
  {"buildings", "gold"}
  {"buildings", "jewelry"}
  {"buildings", "library"}
  {"buildings", "microchips"}
  {"buildings", "mountains"}
  {"buildings", "oil"}
  {"buildings", "plastic"}
  {"buildings", "power-plant"}
  {"buildings", "toys"}
  {"buildings", "tree"}
  {"buildings", "wires"}

  {"buttons", "button-bg"}
  {"buttons", "pause"}
  {"buttons", "play"}
  {"buttons", "slot"}
  {"buttons", "toolbar"}

  {"misc", "arrow"}

  {"roads", "road"}
  {"roads", "road-down"}
  {"roads", "road-left"}
  {"roads", "road-left-down"}
  {"roads", "road-left-right"}
  {"roads", "road-left-right-down"}
  {"roads", "road-left-right-up"}
  {"roads", "road-left-right-up-down"}
  {"roads", "road-left-up"}
  {"roads", "road-left-up-down"}
  {"roads", "road-right"}
  {"roads", "road-right-down"}
  {"roads", "road-right-up"}
  {"roads", "road-right-up-down"}
  {"roads", "road-up"}
  {"roads", "road-up-down"}

  {"units", "jeep"}
  {"units", "van"}
  {"units", "truck"}
}

imgs.get = (name) ->
  img = imgs.images[name]
  unless img
    error "image not found: #{name}"
  return img

imgs.load_all = (name) ->
  for t in *to_load
    {dir, name} = t
    path = "art/#{dir}/#{name}.png"
    img = graphics.newImage path
    unless img
      error("image not found: #{img}")
    images[name] = img


