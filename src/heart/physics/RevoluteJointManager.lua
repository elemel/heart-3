local mathUtils = require("heart.math.utils")

local RevoluteJointManager = {}
RevoluteJointManager.__index = RevoluteJointManager
RevoluteJointManager.dependencies = {"transform", "body"}

function RevoluteJointManager.new(...)
  local joint = setmetatable({}, RevoluteJointManager)
  joint:init(...)
  return joint
end

function RevoluteJointManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
  self.transformSystem = assert(self.game.systems.transform)
end

function RevoluteJointManager:createComponent(entityId, config)
  local parentX, parentY, parentAngle =
    self.transformSystem:getWorldTransform(entityId)

  local bodyId2 =
    assert(config.body2 or self.game:findAncestorComponent(entityId, "body"))

  local bodyId1 =
    assert(config.body1 or self.game:findAncestorComponent(bodyId2, "body", 1))

  local body1 = assert(self.physicsSystem.bodies[bodyId1])
  local body2 = assert(self.physicsSystem.bodies[bodyId2])

  local anchorX1 = config.anchorX1 or 0
  local anchorY1 = config.anchorY1 or 0
  local anchorX2 = config.anchorX2 or 0
  local anchorY2 = config.anchorY2 or 0

  anchorX1, anchorY1 =
    mathUtils.toWorldPoint2(anchorX1, anchorY1, parentX, parentY, parentAngle)

  anchorX2, anchorY2 =
    mathUtils.toWorldPoint2(anchorX2, anchorY2, parentX, parentY, parentAngle)

  local collideConnected = config.collideConnected or false
  local referenceAngle = config.referenceAngle or 0

  local joint = love.physics.newRevoluteJoint(
    body1,
    body2,
    anchorX1,
    anchorY1,
    anchorX2,
    anchorY2,
    collideConnected,
    referenceAngle)

  joint:setUserData(entityId)

  joint:setMotorEnabled(config.motorEnabled or false)
  joint:setMaxMotorTorque(config.maxMotorTorque or 0)
  joint:setMotorSpeed(config.motorSpeed or 0)

  joint:setLimitsEnabled(config.limitsEnabled or false)
  joint:setLowerLimit(config.lowerLimit or 0)
  joint:setUpperLimit(config.upperLimit or 0)

  self.physicsSystem.revoluteJoints[entityId] = joint
  return joint
end

function RevoluteJointManager:destroyComponent(entityId)
  self.physicsSystem.revoluteJoints[entityId]:destroy()
  self.physicsSystem.revoluteJoints[entityId] = nil
end

return RevoluteJointManager
