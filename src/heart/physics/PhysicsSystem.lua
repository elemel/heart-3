local BodyComponentManager = require("heart.physics.BodyComponentManager")

local ChainFixtureComponentManager =
  require("heart.physics.ChainFixtureComponentManager")

local CircleFixtureComponentManager =
  require("heart.physics.CircleFixtureComponentManager")

local MotorJointComponentManager =
  require("heart.physics.MotorJointComponentManager")

local PolygonFixtureComponentManager =
  require("heart.physics.PolygonFixtureComponentManager")

local PrismaticJointComponentManager =
  require("heart.physics.PrismaticJointComponentManager")

local RectangleFixtureComponentManager =
  require("heart.physics.RectangleFixtureComponentManager")

local RevoluteJointComponentManager =
  require("heart.physics.RevoluteJointComponentManager")

local Topic = require("heart.event.Topic")

local PhysicsSystem = {}
PhysicsSystem.__index = PhysicsSystem
PhysicsSystem.dependencies = {"fixedUpdate", "transform", "update"}

function PhysicsSystem.new(...)
  local instance = setmetatable({}, PhysicsSystem)
  instance:init(...)
  return instance
end

function PhysicsSystem:init(game, config)
  self.game = assert(game)
  self.fixedUpdateSystem = assert(game.systems.fixedUpdate)
  self.fixedUpdateSystem.topics.physics:subscribe(self, self.updatePhysics)
  self.transformSystem = assert(game.systems.transform)
  local gravityX = config.gravityX or 0
  local gravityY = config.gravityY or 0
  local sleepingAllowed = config.sleepingAllowed ~= false
  self.world = love.physics.newWorld(gravityX, gravityY, sleepingAllowed)

  self.bodies = {}
  self.bodyUpdateTypes = {}

  self.bodyUpdateGroups = {
    static = {},
    dynamic = {},
    kinematic = {},
    animated = {},
  }

  self.chainFixtures = {}
  self.circleFixtures = {}
  self.polygonFixtures = {}
  self.rectangleFixtures = {}
  self.fixtureTangentSpeeds = {}
  self.motorJoints = {}
  self.prismaticJoints = {}
  self.revoluteJoints = {}
  self.nextGroupIndex = 1

  self.world:setCallbacks(
    nil,
    nil,
    self:getPreSolveCallback(),
    nil)

  self.topics = {
    motor = Topic.new(),
    animation = Topic.new(),
    collision = Topic.new(),
  }

  self.game.componentManagers.body = BodyComponentManager.new(self)

  self.game.componentManagers.chainFixture =
    ChainFixtureComponentManager.new(self)

  self.game.componentManagers.circleFixture =
    CircleFixtureComponentManager.new(self)

  self.game.componentManagers.motorJoint = MotorJointComponentManager.new(self)

  self.game.componentManagers.polygonFixture =
    PolygonFixtureComponentManager.new(self)

  self.game.componentManagers.prismaticJoint =
    PrismaticJointComponentManager.new(self)

  self.game.componentManagers.rectangleFixture =
    RectangleFixtureComponentManager.new(self)

  self.game.componentManagers.revoluteJoint =
    RevoluteJointComponentManager.new(self)

  self.game.topics.quit:subscribe(self, self.quit)
end

function PhysicsSystem:updatePhysics(dt)
  local transformSystem = self.transformSystem

  self.topics.motor:publish(dt)

  -- Update kinematic bodies from transforms
  for entityId, body in pairs(self.bodyUpdateGroups.kinematic) do
    local x1, y1 = body:getPosition()
    local angle1 = body:getAngle()
    local x2, y2, angle2 = transformSystem:getWorldTransform(entityId)

    local linearVelocityX = (x2 - x1) / dt
    local linearVelocityY = (y2 - y1) / dt
    body:setLinearVelocity(linearVelocityX, linearVelocityY)

    angularVelocity = (angle2 - angle1) / dt
    body:setAngularVelocity(angularVelocity)
  end

  self.world:update(dt)

  -- Update transforms from dynamic bodies
  for entityId, body in pairs(self.bodyUpdateGroups.dynamic) do
    local x, y = body:getPosition()
    local angle = body:getAngle()
    transformSystem:setParent(entityId, nil)
    transformSystem:getTransform(entityId):reset():translate(x, y):rotate(angle)
    transformSystem:setDirty(entityId, true)
  end

  self.topics.animation:publish(dt)

  if next(self.bodyUpdateGroups.animated) then
    local transformSystem = self.transformSystem

    -- Update animated bodies from transforms
    for entityId, body in pairs(self.bodyUpdateGroups.animated) do
      local x, y, angle = transformSystem:getWorldTransform(entityId)
      body:setPosition(x, y)
      body:setAngle(angle)
    end

    -- Create a temporary fixture to force collision update
    local body = love.physics.newBody(self.world)
    local shape = love.physics.newCircleShape(1)
    local fixture = love.physics.newFixture(body, shape)
    fixture:destroy()
    body:destroy()

    -- Update animated body collisions
    self.world:update(0)
  end

  self.topics.collision:publish(dt)
end

function PhysicsSystem:generateGroupIndex()
  local groupIndex = self.nextGroupIndex
  self.nextGroupIndex = self.nextGroupIndex + 1
  return groupIndex
end

function PhysicsSystem:getPreSolveCallback()
  local tangentSpeeds = self.fixtureTangentSpeeds

  return function(fixture1, fixture2, contact)
    local tangentSpeed1 = tangentSpeeds[fixture1]
    local tangentSpeed2 = tangentSpeeds[fixture2]

    if tangentSpeed1 or tangentSpeed2 then
      local tangentSpeed = (tangentSpeed1 or 0) + (tangentSpeed2 or 0)
      contact:setTangentSpeed(tangentSpeed)
    end
  end
end

function PhysicsSystem:quit()
end

return PhysicsSystem
