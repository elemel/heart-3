local SpriteComponentManager = {}
SpriteComponentManager.__index = SpriteComponentManager
SpriteComponentManager.dependencies = {"transform"}

function SpriteComponentManager.new(...)
  local instance = setmetatable({}, SpriteComponentManager)
  instance:init(...)
  return instance
end

function SpriteComponentManager:init(graphicsSystem)
  self.graphicsSystem = assert(graphicsSystem)
end

function SpriteComponentManager:createComponent(entityId, config)
  local z = config.z or 0
  self.graphicsSystem.spriteZs[entityId] = z
  self.graphicsSystem.spriteScaleXs[entityId] = config.scaleX or 1
  self.graphicsSystem.spriteScaleYs[entityId] = config.scaleY or 1
  self.graphicsSystem.spriteAlignmentXs[entityId] = config.alignmentX or 0.5
  self.graphicsSystem.spriteAlignmentYs[entityId] = config.alignmentY or 0.5
  local layer = self.graphicsSystem:createLayer(z)
  local imageFilename = assert(config.image)
  local image = love.graphics.newImage(imageFilename)
  image:setFilter("nearest", "nearest")
  layer.spriteImages[entityId] = image
end

function SpriteComponentManager:destroyComponent(entityId)
  local z = assert(self.graphicsSystem.spriteZs[entityId])
  self.graphicsSystem.spriteZs[entityId] = nil
  self.graphicsSystem.spriteScaleXs[entityId] = nil
  self.graphicsSystem.spriteScaleYs[entityId] = nil
  self.graphicsSystem.spriteAlignmentXs[entityId] = nil
  self.graphicsSystem.spriteAlignmentYs[entityId] = nil
  local layer = assert(self.graphicsSystem.layers[z])
  layer.spriteImages[entityId] = nil
end

return SpriteComponentManager
