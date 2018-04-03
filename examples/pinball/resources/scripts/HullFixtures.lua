local heartUtils = require("heart.utils")

local HullFixtures = {}
HullFixtures.__index = HullFixtures
HullFixtures.dependencies = {"body", "transform"}

function HullFixtures.new(...)
  local flipper = setmetatable({}, HullFixtures)
  flipper:init(...)
  return flipper
end

function HullFixtures:init(game, entityId, config)
  self.game = assert(game)
  self.entityId = assert(entityId)
  local circlesConfig = assert(config.circles)
  assert(#circlesConfig % 3 == 0)
  assert(#circlesConfig >= 6 and #circlesConfig <= 12)
  local x1 = circlesConfig[#circlesConfig - 2]
  local y1 = circlesConfig[#circlesConfig - 1]
  local radius1 = circlesConfig[#circlesConfig]
  local polygonPoints = {}

  for i = 1, #circlesConfig, 3 do
    local x2 = circlesConfig[i]
    local y2 = circlesConfig[i + 1]
    local radius2 = circlesConfig[i + 2]

    self.game:createEntity({
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

    table.insert(polygonPoints, x3)
    table.insert(polygonPoints, y3)
    table.insert(polygonPoints, x4)
    table.insert(polygonPoints, y4)

    x1 = x2
    y1 = y2
    radius1 = radius2
  end

  self.game:createEntity({
    components = {
      transform = {},

      polygonFixture = {
        points = polygonPoints,
      },
    },
  }, self.entityId)
end

return HullFixtures
