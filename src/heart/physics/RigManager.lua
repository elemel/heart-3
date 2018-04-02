local Matrix = require("heart.math.Matrix")
local mathUtils = require("heart.math.utils")

local RigManager = {}
RigManager.__index = RigManager
RigManager.dependencies = {"transform"}

function RigManager.new(...)
  local instance = setmetatable({}, RigManager)
  instance:init(...)
  return instance
end

function RigManager:init(physicsSystem)
  self.physicsSystem = assert(physicsSystem)
  self.game = assert(self.physicsSystem.game)
end

function RigManager:createComponent(entityId, config)
  local rigFilename = assert(config.rig)

  local rigConfig =
    self.physicsSystem.rigLoader:loadRig(rigFilename)

  self.game:createEntity(rigConfig, entityId)
end

function RigManager:destroyComponent(entityId)
end

return RigManager
