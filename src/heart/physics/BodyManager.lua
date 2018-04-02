local BodyManager = {}
BodyManager.__index = BodyManager
BodyManager.dependencies = {"transform"}

function BodyManager.new(...)
  local instance = setmetatable({}, BodyManager)
  instance:init(...)
  return instance
end

function BodyManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
  self.transformSystem = assert(self.game.systems.transform)
end

function BodyManager:createComponent(entityId, config)
  local x, y, angle = self.transformSystem:getWorldTransform(entityId)
  local bodyType = config.bodyType or "static"
  local body = love.physics.newBody(self.physicsSystem.world, x, y, bodyType)
  body:setUserData(entityId)
  body:setAngle(angle)
  local linearVelocityX = config.linearVelocityX or 0
  local linearVelocityY = config.linearVelocityY or 0
  body:setLinearVelocity(linearVelocityX, linearVelocityY)
  body:setFixedRotation(config.fixedRotation or false)
  body:setGravityScale(config.gravityScale or 1)
  body:setSleepingAllowed(config.sleepingAllowed ~= false)

  self.physicsSystem.bodies[entityId] = body
  local updateType = config.animated and "animated" or bodyType
  self.physicsSystem.bodyUpdateTypes[entityId] = updateType
  self.physicsSystem.bodyUpdateGroups[updateType][entityId] = body
  return body
end

function BodyManager:destroyComponent(entityId)
  local updateType = assert(self.physicsSystem.bodyUpdateTypes[entityId])
  self.physicsSystem.bodyUpdateTypes[entityId] = nil
  self.physicsSystem.bodyUpdateGroups[updateType][entityId] = nil
  self.physicsSystem.bodies[entityId]:destroy()
  self.physicsSystem.bodies[entityId] = body
end

return BodyManager
