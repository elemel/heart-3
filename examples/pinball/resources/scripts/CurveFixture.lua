local heartUtils = require("heart.utils")

local CurveFixture = {}
CurveFixture.__index = CurveFixture
CurveFixture.dependencies = {"body", "transform"}

function CurveFixture.new(...)
  local flipper = setmetatable({}, CurveFixture)
  flipper:init(...)
  return flipper
end

function CurveFixture:init(game, entityId, config)
  self.game = assert(game)
  self.entityId = assert(entityId)
  local controlPoints = assert(config.controlPoints)

  self.game:createComponent(self.entityId, "chainFixture", {
    points = {},
  })
end

return CurveFixture
