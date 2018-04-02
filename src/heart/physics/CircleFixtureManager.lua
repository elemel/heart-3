local mathUtils = require("heart.math.utils")

local CircleFixtureManager = {}
CircleFixtureManager.__index = CircleFixtureManager
CircleFixtureManager.dependencies = {"body", "transform"}

function CircleFixtureManager.new(...)
  local instance = setmetatable({}, CircleFixtureManager)
  instance:init(...)
  return instance
end

function CircleFixtureManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
  self.transformSystem = assert(self.game.systems.transform)
end

function CircleFixtureManager:createComponent(entityId, config)
  local bodyId = assert(self.game:findAncestorComponent(entityId, "body"))
  local body = assert(self.physicsSystem.bodies[bodyId])
  local x = config.x or 0
  local y = config.y or 0

  local parentX, parentY, parentAngle =
    self.transformSystem:getWorldTransform(entityId)

  x, y = mathUtils.toWorldPoint2(x, y, parentX, parentY, parentAngle)
  x, y = body:getLocalPoint(x, y)
  local radius = config.radius or 0.5
  local shape = love.physics.newCircleShape(x, y, radius)
  local density = config.density or 1
  local fixture = love.physics.newFixture(body, shape, density)
  fixture:setUserData(entityId)
  fixture:setFriction(config.friction or 0.2)
  fixture:setGroupIndex(config.groupIndex or 0)
  fixture:setSensor(config.sensor or false)
  self.physicsSystem.circleFixtures[entityId] = fixture
  local tangentSpeed = config.tangentSpeed or 0

  if tangentSpeed ~= 0 then
    self.physicsSystem.fixtureTangentSpeeds[fixture] = tangentSpeed
  end

  return fixture
end

function CircleFixtureManager:destroyComponent(entityId)
  local fixture = assert(self.physicsSystem.circleFixtures[entityId])
  self.physicsSystem.fixtureTangentSpeeds[fixture] = nil
  fixture:destroy()
  self.physicsSystem.circleFixtures[entityId] = nil
end

return CircleFixtureManager
