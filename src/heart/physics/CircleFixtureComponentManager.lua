local heartMath = require("heart.math")

local CircleFixtureComponentManager = {}
CircleFixtureComponentManager.__index = CircleFixtureComponentManager
CircleFixtureComponentManager.dependencies = {"body", "transform"}

function CircleFixtureComponentManager.new(...)
  local instance = setmetatable({}, CircleFixtureComponentManager)
  instance:init(...)
  return instance
end

function CircleFixtureComponentManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
  self.transformSystem = assert(self.game.systems.transform)
end

function CircleFixtureComponentManager:createComponent(entityId, config)
  local bodyId = assert(self.game:findAncestorComponent(entityId, "body"))
  local body = assert(self.physicsSystem.bodies[bodyId])
  local x = config.x or 0
  local y = config.y or 0
  local transform = self.transformSystem:getWorldTransform(entityId)
  x, y = transform:transformPoint(x, y)
  x, y = body:getLocalPoint(x, y)
  local radius = config.radius or 0.5
  local shape = love.physics.newCircleShape(x, y, radius)
  local density = config.density or 1
  local fixture = love.physics.newFixture(body, shape, density)
  fixture:setUserData(entityId)
  fixture:setFriction(config.friction or 0.2)
  fixture:setRestitution(config.restitution or 0)
  fixture:setGroupIndex(config.groupIndex or 0)
  fixture:setSensor(config.sensor or false)
  self.physicsSystem.circleFixtures[entityId] = fixture
  local tangentSpeed = config.tangentSpeed or 0

  if tangentSpeed ~= 0 then
    self.physicsSystem.fixtureTangentSpeeds[fixture] = tangentSpeed
  end

  return fixture
end

function CircleFixtureComponentManager:destroyComponent(entityId)
  local fixture = assert(self.physicsSystem.circleFixtures[entityId])
  self.physicsSystem.fixtureTangentSpeeds[fixture] = nil
  fixture:destroy()
  self.physicsSystem.circleFixtures[entityId] = nil
end

return CircleFixtureComponentManager
