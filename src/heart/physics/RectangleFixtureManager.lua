local mathUtils = require("heart.math.utils")

local RectangleFixtureManager = {}
RectangleFixtureManager.__index = RectangleFixtureManager
RectangleFixtureManager.dependencies = {"body"}

function RectangleFixtureManager.new(...)
  local instance = setmetatable({}, RectangleFixtureManager)
  instance:init(...)
  return instance
end

function RectangleFixtureManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
  self.transformSystem = assert(self.game.systems.transform)
end

function RectangleFixtureManager:createComponent(entityId, config)
  local bodyId =
    assert(config.body or self.game:findAncestorComponent(entityId, "body"))

  local body = assert(self.physicsSystem.bodies[bodyId])
  local x = config.x or 0
  local y = config.y or 0
  local angle = config.angle or 0

  local parentX, parentY, parentAngle =
    self.transformSystem:getWorldTransform(entityId)

  x, y, angle =
    mathUtils.toWorldTransform2(x, y, angle, parentX, parentY, parentAngle)

  x, y = body:getLocalPoint(x, y)
  angle = angle - body:getAngle()
  local width = config.width or 1
  local height = config.height or 1
  local shape = love.physics.newRectangleShape(x, y, width, height, angle)
  local density = config.density or 1
  local fixture = love.physics.newFixture(body, shape, density)
  fixture:setUserData(entityId)
  fixture:setFriction(config.friction or 0.2)
  fixture:setGroupIndex(config.groupIndex or 0)
  fixture:setSensor(config.sensor or false)
  self.physicsSystem.rectangleFixtures[entityId] = fixture
  return fixture
end

function RectangleFixtureManager:destroyComponent(entityId)
  self.physicsSystem.rectangleFixtures[entityId]:destroy()
  self.physicsSystem.rectangleFixtures[entityId] = nil
end

return RectangleFixtureManager
