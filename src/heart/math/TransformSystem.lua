local mathUtils = require("heart.math.utils")

local TransformComponentManager =
  require("heart.math.TransformComponentManager")

local utils = require("heart.utils")

local TransformSystem = {}
TransformSystem.__index = TransformSystem
TransformSystem.dependencies = {"fixedUpdate"}

function TransformSystem.new(...)
  local instance = setmetatable({}, TransformSystem)
  instance:init(...)
  return instance 
end

function TransformSystem:init(game)
  self.game = assert(game)
  self.transforms = {}
  self.worldTransforms = {}
  self.dirty = {}
  self.parents = {}
  self.children = {}
  self.game.componentManagers.transform = TransformComponentManager.new(self)
  self.fixedUpdateSystem = assert(self.game.systems.fixedUpdate)
  self.fixedUpdateSystem.topics.physics:subscribe(self, self.fixedUpdate)
end

function TransformSystem:fixedUpdate(dt)
end

function TransformSystem:setMode(entityId, mode)
  assert(mode == "local" or mode == "world")
  local currentMode = assert(self.modes[entityId])

  if mode ~= currentMode then
    self:setDirty(entityId, false)
    self.modes[entityId] = mode
  end
end

function TransformSystem:setParent(entityId, parentId, mode)
  mode = mode or "local"
  assert(mode == "local" or mode == "world")
  local currentParentId = self.parents[entityId]

  if parentId ~= currentParentId then
    if mode == "world" then
      self:setDirty(entityId, false)
    end

    if currentParentId then
      local siblings = self.children[currentParentId]
      siblings[entityId] = nil

      if not next(siblings) then
        self.children[currentParentId] = nil
      end
    end

    self.parents[entityId] = parentId

    if parentId then
      local siblings = self.children[parentId]

      if not siblings then
        siblings = {}
        self.children[parentId] = siblings
      end

      siblings[entityId] = true
    end

    if mode == "world" then
      local transform = self.transforms[entityId]
      local worldTransform = self.worldTransforms[entityId]
      transform:reset()

      if parentId then
        self:setDirty(parentId, false)
        local parentWorldTransform = self.worldTransforms[parentId]
        transform:apply(parentWorldTransform:inverse())
      end

      transform:apply(worldTransform)
    end

    self:setDirty(entityId, true)
  end
end

function TransformSystem:setDirty(entityId, dirty)
  assert(type(dirty) == "boolean")
  local currentDirty = self.dirty[entityId] or false

  if dirty ~= currentDirty then
    if dirty then
      local children = self.children[entityId]

      if children then
        for childId in pairs(children) do
          self:setDirty(childId, true)
        end
      end

      self.dirty[entityId] = true
    else
      local transform = self.transforms[entityId]
      local worldTransform = self.worldTransforms[entityId]
      worldTransform:reset()
      local parentId = self.parents[entityId]

      if parentId then
        self:setDirty(parentId, false)
        local parentWorldTransform = self.worldTransforms[parentId]
        worldTransform:apply(parentWorldTransform)
      end

      worldTransform:apply(transform)
      self.dirty[entityId] = nil
    end
  end
end

function TransformSystem:getTransform(entityId, t)
  return self.transforms[entityId]
end

function TransformSystem:getWorldTransform(entityId, t)
  self:setDirty(entityId, false)
  return self.worldTransforms[entityId]
end

return TransformSystem
