local debug = require("heart.debug")
local svg = require("heart.svg")
local xml = require("heart.external.xml")

local RigLoader = {}
RigLoader.__index = RigLoader

function RigLoader.new(...)
  local instance = setmetatable({}, RigLoader)
  instance:init(...)
  return instance
end

function RigLoader:init()
end

function RigLoader:loadRig(filename)
  local text = assert(love.filesystem.read(filename))
  local doc = xml.collect(text)
  local element = svg.findElement(doc, "inkscape:label", "rig")

  local config = {
    components = {
      transform = {},
      body = {},
    },

    children = {},
  }

  self:loadElement(element, config)
  print(debug.dump(config, "pretty"))
  return config
end

function RigLoader:loadElement(t, config)
  if t.label == "g" then
    local childConfig = {
      components = {
        transform = {},
        body = {},
      },

      children = {},
    }

    for i, v in ipairs(t) do
      if type(v) == "table" then
        self:loadElement(v, childConfig)
      end
    end

    table.insert(config.children, childConfig)
  elseif t.label == "circle" then
    x = 0.001 * tonumber(t.xarg.cx)
    y = 0.001 * tonumber(t.xarg.cy)

    config.components.transform = {
      x = x,
      y = y,
    }
  end
end

return RigLoader
