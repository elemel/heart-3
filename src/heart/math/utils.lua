local acos = math.acos
local cos = math.cos
local max = math.max
local min = math.min
local pi = math.pi
local sin = math.sin
local sqrt = math.sqrt

function sign(x)
  return x < 0 and -1 or 1
end

function clamp(x, x1, x2)
  return min(max(x, x1), x2)
end

function length2(x, y)
  return sqrt(x * x + y * y)
end

function distance2(x1, y1, x2, y2)
  return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
end

function dot2(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end

function cross2(x1, y1, x2, y2)
  return x1 * y2 - x2 * y1
end

function normalize2(x, y)
  local length = length2(x, y)

  if length == 0 then
    return 1, 0, 0
  end

  return x / length, y / length, length
end

function clampLength2(x, y, minLength, maxLength)
  local x, y, length = normalize2(x, y)
  local clampedLength = clamp(length, minLength, maxLength)
  return x * clampedLength, y * clampedLength, length
end

function mix(x1, x2, t)
  return (1 - t) * x1 + t * x2
end

function mix2(x1, y1, x2, y2, t)
  return (1 - t) * x1 + t * x2, (1 - t) * y1 + t * y2
end

function normalizeAngle(a)
  return (a + pi) % (2 * pi) - pi
end

function mixAngles(a1, a2, t)
  return a1 + normalizeAngle(a2 - a1) * t
end

function rotate2(x, y, angle)
  local cosAngle = cos(angle)
  local sinAngle = sin(angle)
  return cosAngle * x + -sinAngle * y, sinAngle * x + cosAngle * y
end

function toLocalPoint2(worldX, worldY, parentX, parentY, parentAngle)
  local rotatedX = worldX - parentX
  local rotatedY = worldY - parentY
  local localX, localY = rotate2(rotatedX, rotatedY, -parentAngle)
  return localX, localY
end

function toWorldPoint2(localX, localY, parentX, parentY, parentAngle)
  local rotatedX, rotatedY = rotate2(localX, localY, parentAngle)
  local worldX = rotatedX + parentX
  local worldY = rotatedY + parentY
  return worldX, worldY
end

function toLocalTransform2(
  worldX, worldY, worldAngle, parentX, parentY, parentAngle)

  local rotatedX = worldX - parentX
  local rotatedY = worldY - parentY
  local localX, localY = rotate2(rotatedX, rotatedY, -parentAngle)
  local localAngle = worldAngle - parentAngle
  return localX, localY, localAngle
end

function toWorldTransform2(
  localX, localY, localAngle, parentX, parentY, parentAngle)

  local rotatedX, rotatedY = rotate2(localX, localY, parentAngle)
  local worldX = rotatedX + parentX
  local worldY = rotatedY + parentY
  local worldAngle = localAngle + parentAngle
  return worldX, worldY, worldAngle
end

-- http://frederic-wang.fr/decomposition-of-2d-transform-matrices.html
function decompose2(transform)
  local t11, t12, t13, t14,
    t21, t22, t23, t24,
    t31, t32, t33, t34,
    t41, t42, t43, t44 = transform:getMatrix()

  local x = t14
  local y = t24
  local angle = 0
  local scaleX = t11 * t11 + t21 * t21
  local scaleY = t12 * t12 + t22 * t22
  local skewX = 0
  local skewY = 0

  if scaleX + scaleY ~= 0 then
    local det = t11 * t22 - t12 * t21

    if scaleX >= scaleY then
      skewX = (t11 * t12 + t21 * t22) / scaleX
      scaleX = sqrt(scaleX)
      angle = sign(t11) * acos(t11 / scaleX)
      scaleY = det / scaleX
    else
      skewY = (t11 * t12 + t21 * t22) / scaleY
      scaleY = sqrt(scaleY)
      angle = 0.5 * pi - sign(t22) * acos(-t12 / scaleY)
      scaleX = det / scaleY
    end
  end

  return x, y, angle, scaleX, scaleY, 0, 0, skewX, skewY
end

return {
  clamp = clamp,
  clampLength2 = clampLength2,
  cross2 = cross2,
  decompose2 = decompose2,
  distance2 = distance2,
  dot2 = dot2,
  length2 = length2,
  mix = mix,
  mix2 = mix2,
  mixAngles = mixAngles,
  normalize2 = normalize2,
  normalizeAngle = normalizeAngle,
  rotate2 = rotate2,
  sign = sign,
  toLocalPoint2 = toLocalPoint2,
  toLocalTransform2 = toLocalTransform2,
  toWorldPoint2 = toWorldPoint2,
  toWorldTransform2 = toWorldTransform2,
}
