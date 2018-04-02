local heartString = require("heart.string")

local svg = {}

function svg.parseStyle(s)
  local style = {}
  local attrs = heartString.split(s, ";")

  for i, attr in ipairs(attrs) do
    local k, v = unpack(heartString.split(attr, ":"))
    style[k] = v
  end

  return style
end

function svg.parseColor(s)
  s = s:gsub("#", "")

  return tonumber("0x" .. s:sub(1, 2)),
    tonumber("0x" .. s:sub(3, 4)),
    tonumber("0x" .. s:sub(5,6))
end

function svg.parsePath(s)
  local path = {}

  string.gsub(s, "([-%d.]+),([-%d.]+)", function (x, y)
    table.insert(path, x)
    table.insert(path, y)
  end)

  return path
end

function svg.findElement(t, k, v)
  if t.xarg and t.xarg[k] == v then
    return t
  end

  for i, child in ipairs(t) do
    if type(child) == "table" then
      local element = svg.findElement(child, k, v)

      if element then
        return element
      end
    end
  end

  return nil
end

return svg
