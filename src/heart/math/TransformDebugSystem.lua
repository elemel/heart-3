local TransformDebugSystem = {}
TransformDebugSystem.__index = TransformDebugSystem
TransformDebugSystem.dependencies = {"graphics", "transform"}

function TransformDebugSystem.new(...)
  local instance = setmetatable({}, TransformDebugSystem)
  instance:init(...)
  return instance 
end

function TransformDebugSystem:init(game, config)
  self.game = assert(game)
  self.graphicsSystem = assert(self.game.systems.graphics)
  self.graphicsSystem.topics.debug:subscribe(self, self.draw)
  self.transformSystem = assert(self.game.systems.transform)
  self.color = config.color or {0, 1, 0, 1}
end

function TransformDebugSystem:draw()
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(self.color)

  for entityId, parentId in pairs(self.transformSystem.parents) do
    local x1, y1, _ = self.transformSystem:getWorldTransform(parentId)
    local x2, y2, _ = self.transformSystem:getWorldTransform(entityId)
    love.graphics.line(x1, y1, x2, y2)
  end

  love.graphics.setColor(r, g, b, a)
end

return TransformDebugSystem
