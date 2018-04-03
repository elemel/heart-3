local Flipper = {}
Flipper.__index = Flipper
Flipper.dependencies = {"revoluteJoint"}

function Flipper.new(...)
  local flipper = setmetatable({}, Flipper)
  flipper:init(...)
  return flipper
end

function Flipper:init(game, entityId, config)
  self.game = assert(game)
  self.entityId = assert(entityId)
  self.physicsSystem = assert(self.game.systems.physics)
  self.physicsSystem.topics.motor:subscribe(self, self.updateMotor)
  self.revoluteJoint = assert(self.physicsSystem.revoluteJoints[self.entityId])
  self.direction = config.direction or 1
  self.speed = config.speed or 1
  self.key = config.key or "lshift"
end

function Flipper:destroy()
  self.physicsSystem.topics.motor:unsubscribe(self)
end

function Flipper:updateMotor(dt)
  local direction = love.keyboard.isDown(self.key) and 1 or -1
  local speed = direction * self.direction * self.speed
  self.revoluteJoint:setMotorSpeed(speed)
end

return Flipper
