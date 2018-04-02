local PhysicsDebugSystem = {}
PhysicsDebugSystem.__index = PhysicsDebugSystem
PhysicsDebugSystem.dependencies = {"graphics", "physics"}

function PhysicsDebugSystem.new(...)
  local instance = setmetatable({}, PhysicsDebugSystem)
  instance:init(...)
  return instance
end

function PhysicsDebugSystem:init(game, config)
  self.game = assert(game)
  self.graphicsSystem = assert(self.game.systems.graphics)
  self.graphicsSystem.topics.debug:subscribe(self, self.draw)
  self.physicsSystem = assert(self.game.systems.physics)

  self.colors = config.colors or {
    fixture = {0x00, 0xff, 0x00, 0xff},
  }
end

function PhysicsDebugSystem:draw()
  local r, g, b, a = love.graphics.getColor()

  for i, body in ipairs(self.physicsSystem.world:getBodyList()) do
    local bodyComponent = body:getUserData()

    if self.colors["fixture"] then
      love.graphics.setColor(self.colors["fixture"])

      for j, fixture in ipairs(body:getFixtureList()) do
        local shape = fixture:getShape()
        local shapeType = shape:getType()

        if shapeType == "polygon" then
          love.graphics.polygon(
              "line", body:getWorldPoints(shape:getPoints()))
        elseif shapeType == "circle" then
          local x, y = body:getWorldPoint(shape:getPoint())
          local radius = shape:getRadius()
          love.graphics.circle("line", x, y, radius, 16)
          local angle = body:getAngle()

          love.graphics.line(
              x,
              y,
              x + radius * math.cos(angle),
              y + radius * math.sin(angle))
        elseif shapeType == "chain" then
          love.graphics.line(body:getWorldPoints(shape:getPoints()))
        end
      end
    end
  end

  for i, joint in ipairs(self.physicsSystem.world:getJointList()) do
    local jointType = joint:getType()

    if self.colors[jointType] then
      love.graphics.setColor(self.colors[jointType])

      local x1, y1, x2, y2 = joint:getAnchors()
      love.graphics.line(x1, y1, x2, y2)
    end
  end

  love.graphics.setColor(r, g, b, a)
end

return PhysicsDebugSystem
