local ScriptManager = {}
ScriptManager.__index = ScriptManager

function ScriptManager.new(...)
  local instance = setmetatable({}, ScriptManager)
  instance:init(...)
  return instance
end

function ScriptManager:init(scriptSystem, componentType, dependencies)
  self.scriptSystem = assert(scriptSystem)
  self.componentType = assert(componentType)
  self.dependencies = dependencies
  self.game = assert(self.scriptSystem.game)
  self.scriptClass = assert(self.scriptSystem.scriptClasses[self.componentType])
  self.scripts = assert(self.scriptSystem.scripts[self.componentType])
end

function ScriptManager:createComponent(entityId, config)
  local script = assert(self.scriptClass.new(self.game, entityId, config))
  self.scripts[entityId] = script
  return script
end

function ScriptManager:destroyComponent(entityId)
  local script = assert(self.scripts[entityId])
  self.scripts[entityId] = nil

  if script.destroy then
    script:destroy()
  end
end

return ScriptManager
