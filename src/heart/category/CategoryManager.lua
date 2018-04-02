local CategoryManager = {}
CategoryManager.__index = CategoryManager

function CategoryManager.new(...)
  local instance = setmetatable({}, CategoryManager)
  instance:init(...)
  return instance
end

function CategoryManager:init(categorySystem, componentType)
  self.categorySystem = assert(categorySystem)
  self.componentType = assert(componentType)
  self.category = assert(self.categorySystem.categories[self.componentType])
end

function CategoryManager:createComponent(entityId, config)
  self.category[entityId] = true
end

function CategoryManager:destroyComponent(entityId)
  self.category[entityId] = nil
end

return CategoryManager
