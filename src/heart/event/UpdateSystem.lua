local Topic = require("heart.event.Topic")

local UpdateSystem = {}
UpdateSystem.__index = UpdateSystem

function UpdateSystem.new(...)
  local system = setmetatable({}, UpdateSystem)
  system:init(...)
  return system
end

function UpdateSystem:init(game, config)
  self.game = assert(game)
  self.game.topics.update:subscribe(self, self.update)
  self.topics = {}

  if config.topics then
    for i, topicName in ipairs(config.topics) do
      local topic = Topic.new()
      table.insert(self.topics, topic)
      self.topics[topicName] = topic
    end
  end
end

function UpdateSystem:update(dt)
  for i, topic in ipairs(self.topics) do
    topic:publish(dt)
  end
end

return UpdateSystem
