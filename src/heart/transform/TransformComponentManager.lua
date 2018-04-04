local Matrix = require("heart.math.Matrix")
local mathUtils = require("heart.math.utils")

local TransformComponentManager = {}
TransformComponentManager.__index = TransformComponentManager

function TransformComponentManager.new(...)
  local instance = setmetatable({}, TransformComponentManager)
  instance:init(...)
  return instance
end

function TransformComponentManager:init(transformSystem)
  self.transformSystem = assert(transformSystem)
  self.game = assert(self.transformSystem.game)
end

function TransformComponentManager:createComponent(entityId, config)
  local x = config.x or 0
  local y = config.y or 0
  local angle = config.angle or 0
  local worldX = x
  local worldY = y
  local worldAngle = angle
  local parentId = config.parent or self.game.parentEntities[entityId]

  if parentId then
    local parentX, parentY, parentAngle =
      self.transformSystem:getWorldTransform(parentId)

    worldX, worldY, worldAngle =
      mathUtils.toWorldTransform2(
        worldX, worldY, worldAngle, parentX, parentY, parentAngle)
  end

  self.transformSystem.previousXs[entityId] = x
  self.transformSystem.previousYs[entityId] = y
  self.transformSystem.previousAngles[entityId] = angle
  self.transformSystem.previousWorldXs[entityId] = worldX
  self.transformSystem.previousWorldYs[entityId] = worldY
  self.transformSystem.previousWorldAngles[entityId] = worldAngle
  self.transformSystem.xs[entityId] = x
  self.transformSystem.ys[entityId] = y
  self.transformSystem.angles[entityId] = angle
  self.transformSystem.worldXs[entityId] = worldX
  self.transformSystem.worldYs[entityId] = worldY
  self.transformSystem.worldAngles[entityId] = worldAngle
  self.transformSystem.modes[entityId] = "local"
  self.transformSystem:setParent(entityId, parentId)
end

function TransformComponentManager:destroyComponent(entityId)
  local children = self.transformSystem.children[entityId]

  if children then
    while true do
      local childId = next(children)

      if not childId then
        break
      end

      self.transformSystem:setParent(childId, nil)
    end
  end

  self.transformSystem:setParent(entityId, nil)
  self.transformSystem.previousXs[entityId] = nil
  self.transformSystem.previousYs[entityId] = nil
  self.transformSystem.previousAngles[entityId] = nil
  self.transformSystem.previousWorldXs[entityId] = nil
  self.transformSystem.previousWorldYs[entityId] = nil
  self.transformSystem.previousWorldAngles[entityId] = nil
  self.transformSystem.xs[entityId] = nil
  self.transformSystem.ys[entityId] = nil
  self.transformSystem.angles[entityId] = nil
  self.transformSystem.worldXs[entityId] = nil
  self.transformSystem.worldYs[entityId] = nil
  self.transformSystem.worldAngles[entityId] = nil
  self.transformSystem.modes[entityId] = nil
  self.transformSystem.dirty[entityId] = nil
end

return TransformComponentManager
