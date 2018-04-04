local CategoryComponentManager = {}
CategoryComponentManager.__index = CategoryComponentManager

function CategoryComponentManager.new(...)
  local instance = setmetatable({}, CategoryComponentManager)
  instance:init(...)
  return instance
end

function CategoryComponentManager:init(categorySystem, componentType)
  self.categorySystem = assert(categorySystem)
  self.componentType = assert(componentType)
  self.category = assert(self.categorySystem.categories[self.componentType])
end

function CategoryComponentManager:createComponent(entityId, config)
  self.category[entityId] = true
end

function CategoryComponentManager:destroyComponent(entityId)
  self.category[entityId] = nil
end

return CategoryComponentManager
