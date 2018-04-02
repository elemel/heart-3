local Matrix = require("heart.math.Matrix")
local mathUtils = require("heart.math.utils")

local SkeletonManager = {}
SkeletonManager.__index = SkeletonManager
SkeletonManager.dependencies = {"transform"}

function SkeletonManager.new(...)
  local instance = setmetatable({}, SkeletonManager)
  instance:init(...)
  return instance
end

function SkeletonManager:init(transformSystem)
  self.transformSystem = assert(transformSystem)
  self.game = assert(self.transformSystem.game)
end

function SkeletonManager:createComponent(entityId, config)
  local skeletonFilename = assert(config.skeleton)

  local skeletonConfig =
    self.transformSystem.skeletonLoader:loadSkeleton(skeletonFilename)

  self.game:createEntity(skeletonConfig, entityId)
end

function SkeletonManager:destroyComponent(entityId)
end

return SkeletonManager
