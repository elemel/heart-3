local mathUtils = require("heart.math.utils")

local ChainFixtureManager = {}
ChainFixtureManager.__index = ChainFixtureManager
ChainFixtureManager.dependencies = {"body", "transform"}

function ChainFixtureManager.new(...)
  local instance = setmetatable({}, ChainFixtureManager)
  instance:init(...)
  return instance
end

function ChainFixtureManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
  self.transformSystem = assert(self.game.systems.transform)
end

function ChainFixtureManager:createComponent(entityId, config)
  local bodyId = assert(self.game:findAncestorComponent(entityId, "body"))
  local body = assert(self.physicsSystem.bodies[bodyId])
  local loop = config.loop or false
  local points = assert(config.points)

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

  local shape = love.physics.newChainShape(loop, localPoints)
  local density = config.density or 1
  local fixture = love.physics.newFixture(body, shape, density)
  fixture:setUserData(entityId)
  fixture:setFriction(config.friction or 0.2)
  fixture:setGroupIndex(config.groupIndex or 0)
  fixture:setSensor(config.sensor or false)
  self.physicsSystem.chainFixtures[entityId] = fixture
  local tangentSpeed = config.tangentSpeed or 0

  if tangentSpeed ~= 0 then
    self.physicsSystem.fixtureTangentSpeeds[fixture] = tangentSpeed
  end

  return fixture
end

function ChainFixtureManager:destroyComponent(entityId)
  local fixture = assert(self.physicsSystem.chainFixtures[entityId])
  self.physicsSystem.fixtureTangentSpeeds[fixture] = nil
  fixture:destroy()
  self.physicsSystem.chainFixtures[entityId] = nil
end

return ChainFixtureManager
