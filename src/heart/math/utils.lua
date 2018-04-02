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

return mathUtils
