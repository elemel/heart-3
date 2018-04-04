local MotorJointComponentManager = {}
MotorJointComponentManager.__index = MotorJointComponentManager
MotorJointComponentManager.dependencies = {"transform", "body"}

function MotorJointComponentManager.new(...)
  local joint = setmetatable({}, MotorJointComponentManager)
  joint:init(...)
  return joint
end

function MotorJointComponentManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
end

function MotorJointComponentManager:createComponent(entityId, config)
  local bodyId1 = assert(config.body1)
  local bodyId2 = config.body2 or entityId
  local body1 = assert(self.physicsSystem.bodies[bodyId1])
  local body2 = assert(self.physicsSystem.bodies[bodyId2])
  local correctionFactor = config.correctionFactor or 0.3
  local collideConnected = config.collideConnected or false

  local joint =
      love.physics.newMotorJoint(
          body1, body2, correctionFactor, collideConnected)

  joint:setUserData(entityId)

  local linearOffsetX = config.linearOffsetX or 0
  local linearOffsetY = config.linearOffsetY or 0
  joint:setLinearOffset(linearOffsetX, linearOffsetY)

  joint:setAngularOffset(config.angularOffset or 0)
  joint:setMaxForce(config.maxForce or 0)
  joint:setMaxTorque(config.maxTorque or 0)
  self.physicsSystem.motorJoints[entityId] = joint
  return joint
end

function MotorJointComponentManager:destroyComponent(entityId)
  self.physicsSystem.motorJoints[entityId]:destroy()
  self.physicsSystem.motorJoints[entityId] = nil
end

return MotorJointComponentManager
