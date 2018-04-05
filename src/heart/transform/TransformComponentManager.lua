local heartMath = require("heart.math")

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
  local scaleX = config.scaleX or 1
  local scaleY = config.scaleY or 1
  local originX = config.originX or 0
  local originY = config.originY or 0
  local skewX = config.skewX or 0
  local skewY = config.skewY or 0

  self.transformSystem.transforms[entityId] =
    love.math.newTransform(
      x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY)

  self.transformSystem.worldTransforms[entityId] = love.math.newTransform()
  self.transformSystem.dirty[entityId] = true

  local parentId = config.parent or self.game.parentEntities[entityId]
  self.transformSystem:setParent(entityId, parentId)
end

function TransformComponentManager:destroyComponent(entityId)
  local children = self.transformSystem.children[entityId]

  if children then
    while true do
      for childId in pairs(children) do
        self.transformSystem:setParent(childId, nil, "world")
      end
    end
  end

  self.transformSystem:setParent(entityId, nil)
  self.transformSystem.transforms[entityId] = nil
  self.transformSystem.worldTransforms[entityId] = nil
  self.transformSystem.dirty[entityId] = nil
end

return TransformComponentManager
