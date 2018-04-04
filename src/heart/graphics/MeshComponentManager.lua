local MeshComponentManager = {}
MeshComponentManager.__index = MeshComponentManager
MeshComponentManager.dependencies = {"transform"}

function MeshComponentManager.new(...)
  local instance = setmetatable({}, MeshComponentManager)
  instance:init(...)
  return instance
end

function MeshComponentManager:init(graphicsSystem)
  self.graphicsSystem = assert(graphicsSystem)
end

function MeshComponentManager:createComponent(entityId, config)
  local z = config.z or 0
  self.graphicsSystem.meshZs[entityId] = z
  local layer = self.graphicsSystem:createLayer(z)
  local meshFilename = assert(config.mesh, "Missing mesh")
  local mesh = self.graphicsSystem.meshLoader:loadMesh(meshFilename)
  layer.meshes[entityId] = mesh
end

function MeshComponentManager:destroyComponent(entityId)
  local z = assert(self.graphicsSystem.meshZs[entityId])
  self.graphicsSystem.meshZs[entityId] = nil
  local layer = assert(self.graphicsSystem.layers[z])
  layer.meshes[entityId] = nil
end

return MeshComponentManager
