local CameraManager = {}
CameraManager.__index = CameraManager
CameraManager.dependencies = {"transform"}

function CameraManager.new(...)
  local instance = setmetatable({}, CameraManager)
  instance:init(...)
  return instance
end

function CameraManager:init(graphicsSystem)
  self.graphicsSystem = assert(graphicsSystem)
end

function CameraManager:createComponent(entityId, config)
  self.graphicsSystem.cameraAngles[entityId] = config.angle
  self.graphicsSystem.cameraScales[entityId] = config.scale or 1
end

function CameraManager:destroyComponent(entityId)
  self.graphicsSystem.cameraScales[entityId] = nil
  self.graphicsSystem.cameraAngles[entityId] = nil
end

return CameraManager
