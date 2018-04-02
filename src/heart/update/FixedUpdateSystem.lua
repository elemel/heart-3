local Topic = require("heart.game.Topic")

local FixedUpdateSystem = {}
FixedUpdateSystem.__index = FixedUpdateSystem
FixedUpdateSystem.dependencies = {"update"}

function FixedUpdateSystem.new(...)
  local instance = setmetatable({}, FixedUpdateSystem)
  instance:init(...)
  return instance
end

function FixedUpdateSystem:init(game, config)
  self.game = assert(game)
  self.updateSystem = assert(game.systems.update)
  self.updateSystem.topics.fixedUpdate:subscribe(self, self.update)
  self.topics = {}
  self.fixedDt = config.fixedDt or 1 / 60
  self.accumulatedDt = 0
  self.fixedFrame = 0

  if config.topics then
    for i, topicName in ipairs(config.topics) do
      local topic = Topic.new()
      table.insert(self.topics, topic)
      self.topics[topicName] = topic
    end
  end
end

function FixedUpdateSystem:update(dt)
  self.accumulatedDt = self.accumulatedDt + dt

  while self.accumulatedDt > self.fixedDt do
    self.fixedFrame = self.fixedFrame + 1
    self.accumulatedDt = self.accumulatedDt - self.fixedDt

    for i, topic in ipairs(self.topics) do
      topic:publish(self.fixedDt)
    end
  end
end

return FixedUpdateSystem
