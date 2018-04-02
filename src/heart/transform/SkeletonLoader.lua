local debug = require("heart.debug")
local svg = require("heart.svg")
local xml = require("heart.external.xml")

local SkeletonLoader = {}
SkeletonLoader.__index = SkeletonLoader

function SkeletonLoader.new(...)
  local instance = setmetatable({}, SkeletonLoader)
  instance:init(...)
  return instance
end

function SkeletonLoader:init()
end

function SkeletonLoader:loadSkeleton(filename)
  local text = assert(love.filesystem.read(filename))
  local doc = xml.collect(text)
  local element = svg.findElement(doc, "inkscape:label", "skeleton")

  local config = {
    components = {},
    children = {},
  }

  self:loadElement(element, config)
  config = config.children[1]
  self:makeConfigRelative(config, 0.5 * 2.10, 0.5 * 2.97)
  return config
end

function SkeletonLoader:loadElement(t, config)
  if t.label == "g" then
    local childConfig = {
      components = {},
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

function SkeletonLoader:makeConfigRelative(config, parentX, parentY)
  local x = assert(config.components.transform.x)
  local y = assert(config.components.transform.y)

  for i, childConfig in pairs(config.children) do
    self:makeConfigRelative(childConfig, x, y)
  end

  x = x - parentX
  y = y - parentY
  config.components.transform.x = x
  config.components.transform.y = y
end

return SkeletonLoader
