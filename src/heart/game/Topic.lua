local utils = require("heart.utils")

local Topic = {}
Topic.__index = Topic

function Topic.new(...)
  local instance = setmetatable({}, Topic)
  instance:init(...)
  return instance
end

function Topic:init()
  self.subscribers = {}
  self.handlers = {}
end

function Topic:subscribe(subscriber, handler)
  assert(not self.handlers[subscriber], "Already subscribed")
  assert(handler, "Missing handler")
  table.insert(self.subscribers, subscriber)
  self.handlers[subscriber] = handler
end

function Topic:unsubscribe(subscriber)
  assert(self.handlers[subscriber], "Not subscribed")
  utils.replaceLastValue(self.subscribers, subscriber, false)
  self.handlers[subscriber] = nil
end

function Topic:publish(...)
  local subscribers = self.subscribers
  local handlers = self.handlers
  local n = #subscribers
  local dirty = false

  for i = 1, n do
    local subscriber = subscribers[i]

    if subscriber then
      local handler = handlers[subscriber]
      handler(subscriber, ...)
    else
      dirty = true
    end
  end

  if dirty then
    utils.removeValues(subscribers, false)
  end
end

return Topic
