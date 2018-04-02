local Matrix = {}
Matrix.__index = Matrix

function Matrix.new(a, b, c, d, e, f)
  return setmetatable({
    a or 1, b or 0, c or 0,
    d or 0, e or 1, f or 0,
  }, Matrix)
end

function Matrix:get()
  return unpack(self)
end

function Matrix:reset(a, b, c, d, e, f)
  self[1] = a or 1
  self[2] = b or 0
  self[3] = c or 0

  self[4] = d or 0
  self[5] = e or 1
  self[6] = f or 0

  return self
end

function Matrix:multiply(a, b, c, d, e, f)
  local a2, b2, c2, d2, e2, f2 = unpack(self)

  return self:reset(
    a2 * a + b2 * d,
    a2 * b + b2 * e,
    a2 * c + b2 * f + c2,

    d2 * a + e2 * d,
    d2 * b + e2 * e,
    d2 * c + e2 * f + f2)
end

function Matrix:multiplyRight(a, b, c, d, e, f)
  local a2, b2, c2, d2, e2, f2 = unpack(self)

  return self:reset(
    a * a2 + b * d2,
    a * b2 + b * e2,
    a * c2 + b * f2 + c,

    d * a2 + e * d2,
    d * b2 + e * e2,
    d * c2 + e * f2 + f)
end

function Matrix:translate(x, y)
  return self:multiply(
    1, 0, x,
    0, 1, y)
end

function Matrix:rotate(angle, x, y)
  local cosAngle = math.cos(angle)
  local sinAngle = math.sin(angle)

  if x then
    self:translate(-x, -y)
  end

  self:multiply(
    cosAngle, -sinAngle, 0,
    sinAngle, cosAngle, 0)

  if x then
    self:translate(x, y)
  end

  return self
end

function Matrix:scale(scaleX, scaleY)
  scaleY = scaleY or scaleX

  return self:multiply(
    scaleX, 0, 0,
    0, scaleY, 0)
end

function Matrix:shear(shearX, shearY)
  return self:multiply(
    1, shearX, 0,
    shearY, 1, 0)
end

function Matrix:reflect(angle, x, y)
  local axisY, axisX = math.atan2(angle)

  if x then
    self:translate(-x, -y)
  end

  self:multiply(
    axisX * axisX - axisY * axisY,
    2 * axisX * axisY,
    0,

    2 * axisX * axisY,
    axisY * axisY - axisX * axisX,
    0)

  if x then
    self:translate(x, y)
  end

  return self
end

function Matrix:transformVector(x, y)
  local a, b, c, d, e, f = unpack(self)
  return a * x + b * y, d * x + e * y
end

function Matrix:transformPoint(x, y)
  local a, b, c, d, e, f = unpack(self)
  return a * x + b * y + c, d * x + e * y + f
end

function Matrix:invert()
  local a, b, c, d, e, f = unpack(self)
  local invDeterminant = 1 / (a * e - b * d)

  return self:reset(
    invDeterminant * e,
    invDeterminant * -b,
    invDeterminant * (b * f - c * e),

    invDeterminant * -d,
    invDeterminant * a,
    invDeterminant * (-a * f + c * d))
end

function Matrix:compose(
    x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY)

  if x or y then
    self:translate(x or 0, y or 0)
  end

  if angle then
    self:rotate(angle)
  end

  if scaleX or scaleY then
    self:scale(scaleX or 1, scaleY or scaleX or 1)
  end

  if shearX or shearY then
    self:shear(shearX or 0, shearY or 0)
  end

  if originX or originY then
    self:translate(-(originX or 0), -(originY or 0))
  end

  return self
end

-- TODO: Implement full decomposition
function Matrix:decompose()
  local a, b, c, d, e, f = unpack(self)
  local x = c
  local y = f
  local angle = math.atan2(d, a)
  local scaleX = math.sqrt(a * a + d * d)
  local scaleY = scaleX
  local originX = 0
  local originY = 0
  local shearX = 0
  local shearY = 0
  return x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY
end

return Matrix
