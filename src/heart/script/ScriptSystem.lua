local ScriptManager = require("heart.script.ScriptManager")

local ScriptSystem = {}
ScriptSystem.__index = ScriptSystem

function ScriptSystem.new(...)
  local instance = setmetatable({}, ScriptSystem)
  instance:init(...)
  return instance
end

function ScriptSystem:init(game, config)
  self.game = assert(game)
  self.scriptClasses = {}
  self.scripts = {}

  if config.scripts then
    for componentType, scriptFilename in pairs(config.scripts) do
      local scriptClass = require(scriptFilename)
      self.scriptClasses[componentType] = scriptClass
      self.scripts[componentType] = {}

      self.game.componentManagers[componentType] =
          ScriptManager.new(self, componentType, scriptClass.dependencies)
    end
  end
end

return ScriptSystem
