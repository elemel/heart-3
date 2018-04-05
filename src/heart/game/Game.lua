local Topic = require("heart.event.Topic")
local utils = require("heart.utils")

local Game = {}
Game.__index = Game

function Game.new(...)
  local instance = setmetatable({}, Game)
  instance:init(...)
  return instance
end

function Game:init(context, config)
  self.context = assert(context)
  self:initTopics(config)
  self:initSystems(config)
  self:initComponents(config)
  self:initEntities(config)
end

function Game:initTopics(config)
  self.topics = {}

  if config.topics then
    for i, topicName in pairs(config.topics) do
      local topic = Topic.new()
      table.insert(self.topics, topic)
      self.topics[topicName] = topic
    end
  end
end

function Game:initSystems(config)
  self.systems = {}
  self.componentManagers = {}
  local classes = assert(self.context.systemClasses)
  local dependencies = {}

  for systemType, class in pairs(classes) do
    dependencies[systemType] = class.dependencies or {}
  end

  local ordering = utils.topologicalOrdering(dependencies, true)
  local indices = utils.invert(ordering)

  if config.systems then
    local systemTypes = utils.keys(config.systems)

    table.sort(systemTypes, function(type1, type2)
      local index1 = assert(indices[type1])
      local index2 = assert(indices[type2])
      return index1 < index2
    end)

    for i, systemType in ipairs(systemTypes) do
      local systemConfig = assert(config.systems[systemType])
      local class = assert(classes[systemType])
      local system = class.new(self, systemConfig)
      self.systems[systemType] = system
    end
  end
end

function Game:initComponents(config)
  local dependencies = {}

  for componentType, manager in pairs(self.componentManagers) do
    dependencies[componentType] = manager.dependencies or {}
  end

  local ordering = utils.topologicalOrdering(dependencies, true)
  self.componentIndices = utils.invert(ordering)
end

function Game:initEntities(config)
  self.nextEntityId = 1
  self.parentEntities = {}
  self.childEntities = {}
  self.componentMasks = {}

  if config.entities then
    for i, entityConfig in ipairs(config.entities) do
      self:createEntity(entityConfig)
    end
  end
end

function Game:generateEntityId()
  local parents = self.parentEntities
  local children = self.childEntities
  local masks = self.componentMasks
  local entityId = self.nextEntityId

  while parents[entityId] or children[entityId] or masks[entityId] do
    entityId = entityId + 1
  end

  self.nextEntityId = entityId + 1
  return entityId
end

function Game:createEntity(config, parentId)
  config = self:expandEntityConfig(config)
  local entityId = config.id

  if entityId then
    assert(
      not self.parentEntities[entityId] and
      not self.childEntities[entityId] and
      not self.componentMasks[entityId],
      "Entity already exists")
  else
    entityId = self:generateEntityId()
  end

  parentId = parentId or config.parent
  self:setEntityParent(entityId, parentId)

  if config.components then
    local componentTypes = utils.keys(config.components)

    for i, componentType in ipairs(componentTypes) do
      if not self.componentManagers[componentType] then
        error("No such component: " .. componentType)
      end
    end

    table.sort(componentTypes, function(type1, type2)
      local index1 = assert(self.componentIndices[type1])
      local index2 = assert(self.componentIndices[type2])
      return index1 < index2
    end)

    for i, componentType in ipairs(componentTypes) do
      local componentConfig = assert(config.components[componentType])
      self:createComponent(entityId, componentType, componentConfig)
    end
  end

  if config.children then
    for i, childConfig in ipairs(config.children) do
      self:createEntity(childConfig, entityId)
    end
  end

  return entityId
end

function Game:destroyEntity(entityId)
  local children = self.childEntities[entityId]

  if children then
    local childIds = utils.keys(children)
    table.sort(childIds)

    for i = #childIds, 1, -1 do
      self:destroyEntity(childIds[i])
    end
  end

  local mask = self.componentMasks[entityId]

  if mask then
    local componentTypes = utils.keys(mask)
    local indices = self.componentIndices

    table.sort(componentTypes, function(type1, type2)
      return indices[type1] < indices[type2]
    end)

    for i = #componentTypes, 1, -1 do
      self:destroyComponent(entityId, componentTypes[i])
    end
  end

  self:setEntityParent(entityId, nil)
end

function Game:createComponent(entityId, componentType, config)
  local mask = self.componentMasks[entityId]

  if not mask then
    mask = {}
    self.componentMasks[entityId] = mask
  else
    assert(not mask[componentType], "Component already exists")
  end

  local manager = self.componentManagers[componentType]

  if not manager then
    error("No such component: " .. componentType)
  end

  local component = manager:createComponent(entityId, config)
  mask[componentType] = true
  return component
end

function Game:destroyComponent(entityId, componentType)
  local manager = assert(self.componentManagers[componentType])
  local mask = self.componentMasks[entityId]

  if not mask or not mask[componentType] then
    return false
  end

  manager:destroyComponent(entityId)
  mask[componentType] = nil

  if not next(mask) then
    self.componentMasks[entityId] = nil
  end

  return true
end

function Game:expandEntityConfig(config)
  local prototypeFilename = config.prototype

  if not prototypeFilename then
    return config
  end

  local prototype = require(prototypeFilename)
  prototype = self:expandEntityConfig(prototype)

  local expandedConfig = {
    id = config.id,
    parent = config.parent,
  }

  if config.components or prototype.components then
    expandedConfig.components = {}

    if prototype.components then
      for componentType, componentPrototype in pairs(prototype.components) do
        expandedConfig.components[componentType] = componentPrototype
      end
    end

    if config.components then
      for componentType, componentConfig in pairs(config.components) do
        local componentPrototype = expandedConfig.components[componentType]

        if componentPrototype then
          expandedComponentConfig = {}

          for name, value in pairs(componentPrototype) do
            expandedComponentConfig[name] = value
          end

          for name, value in pairs(componentConfig) do
            expandedComponentConfig[name] = value
          end

          componentConfig = expandedComponentConfig
        end

        expandedConfig.components[componentType] = componentConfig
      end
    end
  end

  if config.children or prototype.children then
    expandedConfig.children = {}

    if prototype.children then
      for i, childConfig in ipairs(prototype.children) do
        childConfig = self:expandEntityConfig(childConfig)
        expandedConfig.children[i] = childConfig
      end
    end

    if config.children then
      for i, childConfig in ipairs(config.children) do
        childConfig = self:expandEntityConfig(childConfig)
        expandedConfig.children[i] = childConfig
      end
    end
  end

  return expandedConfig
end

function Game:findAncestorComponent(
    entityId, componentType, minDistance, maxDistance)

  minDistance = minDistance or 0
  maxDistance = maxDistance or math.huge
  local parents = self.parentEntities
  local masks = self.componentMasks
  local distance = 0

  while entityId and distance < minDistance do
    entityId = parents[entityId]
    distance = distance + 1
  end

  while entityId and distance <= maxDistance do
    local mask = masks[entityId]

    if mask and mask[componentType] then
      return entityId
    end

    entityId = parents[entityId]
    distance = distance + 1
  end

  return nil
end

function Game:setEntityParent(entityId, parentId)
  local currentParentId = self.parentEntities[entityId]

  if parentId ~= currentParentId then
    if currentParentId then
      local siblings = assert(self.childEntities[currentParentId])
      siblings[entityId] = nil

      if not next(siblings) then
        self.childEntities[currentParentId] = nil
      end
    end

    self.parentEntities[entityId] = parentId

    if parentId then
      local siblings = self.childEntities[parentId]

      if not siblings then
        siblings = {}
        self.childEntities[parentId] = siblings
      end

      siblings[entityId] = true
    end
  end
end

return Game
