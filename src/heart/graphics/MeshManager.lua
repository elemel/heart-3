local MeshManager = {}
MeshManager.__index = MeshManager
MeshManager.dependencies = {"transform"}

function MeshManager.new(...)
  local instance = setmetatable({}, MeshManager)
  instance:init(...)
  return instance
end

function MeshManager:init(graphicsSystem)
  self.graphicsSystem = assert(graphicsSystem)
end

function MeshManager:createComponent(entityId, config)
  local z = config.z or 0
  self.graphicsSystem.meshZs[entityId] = z
  local layer = self.graphicsSystem:createLayer(z)
  local meshFilename = assert(config.mesh, "Missing mesh")
  local mesh = self.graphicsSystem.meshLoader:loadMesh(meshFilename)
  layer.meshes[entityId] = mesh
end

function MeshManager:destroyComponent(entityId)
  local z = assert(self.graphicsSystem.meshZs[entityId])
  self.graphicsSystem.meshZs[entityId] = nil
  local layer = assert(self.graphicsSystem.layers[z])
  layer.meshes[entityId] = nil
end

return MeshManager
