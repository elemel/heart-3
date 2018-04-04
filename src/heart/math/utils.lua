local mathUtils = {}

function mathUtils.sign(x)
  return x < 0 and -1 or 1
end

function mathUtils.clamp(x, x1, x2)
  return math.min(math.max(x, x1), x2)
end

function mathUtils.length2(x, y)
  return math.sqrt(x * x + y * y)
end

function mathUtils.distance2(x1, y1, x2, y2)
  return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
end

function mathUtils.dot2(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end

function mathUtils.cross2(x1, y1, x2, y2)
  return x1 * y2 - x2 * y1
end

function mathUtils.normalize2(x, y)
  local length = mathUtils.length2(x, y)

  if length == 0 then
    return 1, 0, 0
  end

  return x / length, y / length, length
end

function mathUtils.clampLength2(x, y, minLength, maxLength)
  local x, y, length = mathUtils.normalize2(x, y)
  local clampedLength = mathUtils.clamp(length, minLength, maxLength)
  return x * clampedLength, y * clampedLength, length
end

function mathUtils.mix(x1, x2, t)
  return (1 - t) * x1 + t * x2
end

function mathUtils.mix2(x1, y1, x2, y2, t)
  return (1 - t) * x1 + t * x2, (1 - t) * y1 + t * y2
end

function mathUtils.normalizeAngle(a)
  return (a + math.pi) % (2 * math.pi) - math.pi
end

function mathUtils.mixAngles(a1, a2, t)
  return a1 + mathUtils.normalizeAngle(a2 - a1) * t
end

function mathUtils.rotate2(x, y, angle)
  local cosAngle = math.cos(angle)
  local sinAngle = math.sin(angle)
  return cosAngle * x + -sinAngle * y, sinAngle * x + cosAngle * y
end

function mathUtils.toLocalPoint2(
  worldX, worldY, parentX, parentY, parentAngle)

  local rotatedX = worldX - parentX
  local rotatedY = worldY - parentY
  local localX, localY = mathUtils.rotate2(rotatedX, rotatedY, -parentAngle)
  return localX, localY
end

function mathUtils.toWorldPoint2(
  localX, localY, parentX, parentY, parentAngle)

  local rotatedX, rotatedY = mathUtils.rotate2(localX, localY, parentAngle)
  local worldX = rotatedX + parentX
  local worldY = rotatedY + parentY
  return worldX, worldY
end

function mathUtils.toLocalTransform2(
  worldX, worldY, worldAngle, parentX, parentY, parentAngle)

  local rotatedX = worldX - parentX
  local rotatedY = worldY - parentY
  local localX, localY = mathUtils.rotate2(rotatedX, rotatedY, -parentAngle)
  local localAngle = worldAngle - parentAngle
  return localX, localY, localAngle
end

function mathUtils.toWorldTransform2(
  localX, localY, localAngle, parentX, parentY, parentAngle)

  local rotatedX, rotatedY = mathUtils.rotate2(localX, localY, parentAngle)
  local worldX = rotatedX + parentX
  local worldY = rotatedY + parentY
  local worldAngle = localAngle + parentAngle
  return worldX, worldY, worldAngle
end

-- http://frederic-wang.fr/decomposition-of-2d-transform-matrices.html
function mathUtils.decompose2(transform)
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
      scaleX = math.sqrt(scaleX)
      angle = mathUtils.sign(t11) * math.acos(t11 / scaleX)
      scaleY = det / scaleX
    else
      skewY = (t11 * t12 + t21 * t22) / scaleY
      scaleY = math.sqrt(scaleY)
      angle = 0.5 * math.pi - mathUtils.sign(t22) * math.acos(-t12 / scaleY)
      scaleX = det / scaleY
    end
  end

  return x, y, angle, scaleX, scaleY, 0, 0, skewX, skewY
end

return mathUtils
