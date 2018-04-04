local CategoryComponentManager =
  require("heart.category.CategoryComponentManager")

local CategorySystem = {}
CategorySystem.__index = CategorySystem

function CategorySystem.new(...)
  local instance = setmetatable({}, CategorySystem)
  instance:init(...)
  return instance
end

function CategorySystem:init(game, config)
  self.game = assert(game)
  self.categories = {}

  if config.categories then
    for i, componentType in ipairs(config.categories) do
      self.categories[componentType] = {}

      self.game.componentManagers[componentType] =
        CategoryComponentManager.new(self, componentType)
    end
  end
end

return CategorySystem
