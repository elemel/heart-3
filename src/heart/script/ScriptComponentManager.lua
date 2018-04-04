local ScriptComponentManager = {}
ScriptComponentManager.__index = ScriptComponentManager

function ScriptComponentManager.new(...)
  local instance = setmetatable({}, ScriptComponentManager)
  instance:init(...)
  return instance
end

function ScriptComponentManager:init(scriptSystem, componentType, dependencies)
  self.scriptSystem = assert(scriptSystem)
  self.componentType = assert(componentType)
  self.dependencies = dependencies
  self.game = assert(self.scriptSystem.game)
  self.scriptClass = assert(self.scriptSystem.scriptClasses[self.componentType])
  self.scripts = assert(self.scriptSystem.scripts[self.componentType])
end

function ScriptComponentManager:createComponent(entityId, config)
  local script = assert(self.scriptClass.new(self.game, entityId, config))
  self.scripts[entityId] = script
  return script
end

function ScriptComponentManager:destroyComponent(entityId)
  local script = assert(self.scripts[entityId])
  self.scripts[entityId] = nil

  if script.destroy then
    script:destroy()
  end
end

return ScriptComponentManager
