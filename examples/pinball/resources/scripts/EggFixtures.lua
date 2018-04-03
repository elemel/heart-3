local heartUtils = require("heart.utils")

local EggFixtures = {}
EggFixtures.__index = EggFixtures
EggFixtures.dependencies = {"body", "transform"}

function EggFixtures.new(...)
  local flipper = setmetatable({}, EggFixtures)
  flipper:init(...)
  return flipper
end

function EggFixtures:init(game, entityId, config)
  self.game = assert(game)
  self.entityId = assert(entityId)
  local x1 = assert(config.x1)
  local y1 = assert(config.y1)
  local radius1 = config.radius1 or 0.5
  local x2 = assert(config.x2)
  local y2 = assert(config.y2)
  local radius2 = config.radius2 or 0.5

  self.circleFixtureId1 = self.game:createEntity({
    components = {
      transform = {},

      circleFixture = {
        x = x1,
        y = y1,
        radius = radius1,
      },
    },
  }, self.entityId)

  self.circleFixtureId2 = self.game:createEntity({
    components = {
      transform = {},

      circleFixture = {
        x = x2,
        y = y2,
        radius = radius2,
      },
    },
  }, self.entityId)

  local x3, y3, x4, y4 =
    heartUtils.circlesTangent(x1, y1, radius1, x2, y2, radius2)

  local x5, y5, x6, y6 =
    heartUtils.circlesTangent(x2, y2, radius2, x1, y1, radius1)

  self.polygonFixtureId = self.game:createEntity({
    components = {
      transform = {},

      polygonFixture = {
        points = {x3, y3, x4, y4, x5, y5, x6, y6},
      },
    },
  }, self.entityId)
end

return EggFixtures
