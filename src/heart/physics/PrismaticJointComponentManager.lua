local PrismaticJointComponentManager = {}
PrismaticJointComponentManager.__index = PrismaticJointComponentManager
PrismaticJointComponentManager.dependencies = {"transform", "body"}

function PrismaticJointComponentManager.new(...)
  local joint = setmetatable({}, PrismaticJointComponentManager)
  joint:init(...)
  return joint
end

function PrismaticJointComponentManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
  self.transformSystem = assert(self.game.systems.transform)
end

function PrismaticJointComponentManager:createComponent(entityId, config)
  local worldMatrix = self.transformSystem:getWorldMatrix(entityId)

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
  anchorX1, anchorY1 = worldMatrix:transformPoint(anchorX1, anchorY1)
  anchorX2, anchorY2 = worldMatrix:transformPoint(anchorX2, anchorY2)

  local axisX = config.axisX or 0
  local axisY = config.axisY or 0
  axisX, axisY = worldMatrix:transformVector(axisX, axisY)

  local collideConnected = config.collideConnected or false
  local referenceAngle = config.referenceAngle or 0

  local joint = love.physics.newPrismaticJoint(
    body1,
    body2,
    anchorX1,
    anchorY1,
    anchorX2,
    anchorY2,
    axisX,
    axisY,
    collideConnected,
    referenceAngle)

  joint:setUserData(entityId)

  joint:setMotorEnabled(config.motorEnabled or false)
  joint:setMaxMotorForce(config.maxMotorForce or 0)
  joint:setMotorSpeed(config.motorSpeed or 0)

  joint:setLimitsEnabled(config.limitsEnabled or false)
  joint:setLowerLimit(config.lowerLimit or 0)
  joint:setUpperLimit(config.upperLimit or 0)

  self.physicsSystem.prismaticJoints[entityId] = joint
  return joint
end

function PrismaticJointComponentManager:destroyComponent(entityId)
  self.physicsSystem.prismaticJoints[entityId]:destroy()
  self.physicsSystem.prismaticJoints[entityId] = nil
end

return PrismaticJointComponentManager
