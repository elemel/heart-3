local CameraComponentManager = {}
CameraComponentManager.__index = CameraComponentManager
CameraComponentManager.dependencies = {"transform"}

function CameraComponentManager.new(...)
  local instance = setmetatable({}, CameraComponentManager)
  instance:init(...)
  return instance
end

function CameraComponentManager:init(graphicsSystem)
  self.graphicsSystem = assert(graphicsSystem)
end

function CameraComponentManager:createComponent(entityId, config)
  self.graphicsSystem.cameraAngles[entityId] = config.angle
  self.graphicsSystem.cameraScales[entityId] = config.scale or 1
end

function CameraComponentManager:destroyComponent(entityId)
  self.graphicsSystem.cameraScales[entityId] = nil
  self.graphicsSystem.cameraAngles[entityId] = nil
end

return CameraComponentManager
