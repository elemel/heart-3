local svg = require("heart.svg")
local xml = require("heart.external.xml")

local MeshLoader = {}
MeshLoader.__index = MeshLoader

function MeshLoader.new(...)
  local instance = setmetatable({}, MeshLoader)
  instance:init(...)
  return instance
end

function MeshLoader:init()
  self.vertexFormat = {
    {"VertexPosition", "float", 2},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "byte", 4},
    {"BoneIndex", "float", 4},
  }
end

function MeshLoader:loadMesh(filename)
  local text = assert(love.filesystem.read(filename))
  local doc = xml.collect(text)
  local element = svg.findElement(doc, "inkscape:label", "skin")
  local vertices = {}
  self:loadElement(element, vertices)
  return love.graphics.newMesh(self.vertexFormat, vertices, "triangles")
end

function MeshLoader:loadElement(t, vertices)
  if t.label == "path" then
    local pathString = assert(t.xarg.d)
    local path = svg.parsePath(pathString)

    if #path >= 6 then
      local triangles = love.math.triangulate(path)
      local styleString = assert(t.xarg.style)
      local style = svg.parseStyle(styleString)
      local colorString = assert(style.fill)
      local r, g, b = svg.parseColor(colorString)
      local a = 255

      for i, triangle in ipairs(triangles) do
        local x1, y1, x2, y2, x3, y3 = unpack(triangle)
        table.insert(vertices, {x1, y1, 0, 0, r, g, b, a, 0})
        table.insert(vertices, {x2, y2, 0, 0, r, g, b, a, 0})
        table.insert(vertices, {x3, y3, 0, 0, r, g, b, a, 0})
      end
    end
  else
    for i, v in ipairs(t) do
      if type(v) == "table" then
        self:loadElement(v, vertices)
      end
    end
  end
end

return MeshLoader
