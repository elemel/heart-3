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
  local x = config.x
  local y = config.y
  local angle = config.angle
  local scaleX = config.scaleX
  local scaleY = config.scaleY
  local originX = config.originX
  local originY = config.originY
  local skewX = config.skewX
  local skewY = config.skewY

  self.transformSystem.parameterLists[entityId] =
    self.transformSystem:allocateParameters()

  self.transformSystem.transforms[entityId] =
    self.transformSystem:allocateTransform()

  local parentId = config.parent or self.game.parentEntities[entityId]
  self.transformSystem:setParent(entityId, parentId)

  self.transformSystem:setParameters(
    entityId, x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY)
end

function TransformComponentManager:destroyComponent(entityId)
  local children = self.transformSystem.childSets[entityId]

  if children then
    for childId in pairs(children) do
      self.transformSystem:setParent(childId, nil, "world")
    end
  end

  self.transformSystem:setParent(entityId, nil)

  local parameters = self.transformSystem.parameterLists[entityId]
  self.transformSystem.parameterLists[entityId] = nil
  table.insert(self.transformSystem.parameterListPool, parameters)

  local transform = self.transformSystem.transforms[entityId]
  self.transformSystem.transforms[entityId] = nil
  table.insert(self.transformSystem.transformPool, transform)

  local worldTransform = self.transformSystem.worldTransforms[entityId]

  if worldTransform then
    self.transformSystem.worldTransforms[entityId] = nil
    table.insert(self.transformSystem.transformPool, worldTransform)
  end

  local previousParameters =
    self.transformSystem.previousParameterLists[entityId]

  if previousParameters then
    self.transformSystem.previousParameterLists[entityId] = nil
    table.insert(self.transformSystem.parameterListPool, previousParameters)
  end

  local interpolatedWorldTransform =
    self.transformSystem.interpolatedWorldTransforms[entityId]

  if interpolatedWorldTransform then
    self.transformSystem.interpolatedWorldTransforms[entityId] = nil
    table.insert(self.transformSystem.transformPool, interpolatedWorldTransform)
  end
end

return TransformComponentManager
