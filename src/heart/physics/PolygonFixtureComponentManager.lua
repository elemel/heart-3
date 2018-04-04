local mathUtils = require("heart.math.utils")

local PolygonFixtureComponentManager = {}
PolygonFixtureComponentManager.__index = PolygonFixtureComponentManager
PolygonFixtureComponentManager.dependencies = {"body"}

function PolygonFixtureComponentManager.new(...)
  local instance = setmetatable({}, PolygonFixtureComponentManager)
  instance:init(...)
  return instance
end

function PolygonFixtureComponentManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
  self.transformSystem = assert(self.game.systems.transform)
end

function PolygonFixtureComponentManager:createComponent(entityId, config)
  local bodyId =
    assert(config.body or self.game:findAncestorComponent(entityId, "body"))

  local body = assert(self.physicsSystem.bodies[bodyId])
  local points = config.points or {-0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5, 0.5}

  local parentX, parentY, parentAngle =
    self.transformSystem:getWorldTransform(entityId)

  local localPoints = {}

  for i = 1, #points, 2 do
    local x = points[i]
    local y = points[i + 1]
    x, y = mathUtils.toWorldPoint2(x, y, parentX, parentY, parentAngle)
    x, y = body:getLocalPoint(x, y)
    table.insert(localPoints, x)
    table.insert(localPoints, y)
  end

  local shape = love.physics.newPolygonShape(localPoints)
  local density = config.density or 1
  local fixture = love.physics.newFixture(body, shape, density)
  fixture:setUserData(entityId)
  fixture:setFriction(config.friction or 0.2)
  fixture:setGroupIndex(config.groupIndex or 0)
  fixture:setSensor(config.sensor or false)
  self.physicsSystem.polygonFixtures[entityId] = fixture
  local tangentSpeed = config.tangentSpeed or 0

  if tangentSpeed ~= 0 then
    self.physicsSystem.fixtureTangentSpeeds[fixture] = tangentSpeed
  end

  return fixture
end

function PolygonFixtureComponentManager:destroyComponent(entityId)
  local fixture = assert(self.physicsSystem.polygonFixtures[entityId])
  self.physicsSystem.fixtureTangentSpeeds[fixture] = nil
  self.physicsSystem.polygonFixtures[entityId]:destroy()
  self.physicsSystem.polygonFixtures[entityId] = nil
end

return PolygonFixtureComponentManager
