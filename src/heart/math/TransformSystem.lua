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
  self.parameterLists = {}
  self.previousParameterLists = {}
  self.transforms = {}
  self.worldTransforms = {}
  self.interpolatedWorldTransforms = {}
  self.parents = {}
  self.childSets = {}
  self.parameterListPool = {}
  self.transformPool = {}
  self.t = 0
  self.game.componentManagers.transform = TransformComponentManager.new(self)
  self.updateSystem = assert(self.game.systems.update)
  self.updateSystem.topics.transform:subscribe(self, self.update)
  self.fixedUpdateSystem = assert(self.game.systems.fixedUpdate)
  self.fixedUpdateSystem.topics.transform:subscribe(self, self.fixedUpdate)
end

function TransformSystem:update(dt)
  print("update", dt)
  self:updateTime()
end

function TransformSystem:fixedUpdate(dt)
  print("fixedUpdate", dt)
  self:updateTime()

  for entityId, previousParameters in pairs(self.previousParameterLists) do
    self.previousParameterLists[entityId] = nil
    table.insert(self.parameterListPool, previousParameters)
  end
end

function TransformSystem:updateTime()
  self.t = self.fixedUpdateSystem.accumulatedDt / self.fixedUpdateSystem.fixedDt

  for entityId, transform in pairs(self.interpolatedWorldTransforms) do
    self.interpolatedWorldTransforms[entityId] = nil
    table.insert(self.transformPool, transform)
  end
end

-- TODO: World mode
function TransformSystem:setParent(entityId, parentId, mode)
  mode = mode or "local"
  assert(mode == "local" or mode == "world")
  local currentParentId = self.parents[entityId]

  if parentId ~= currentParentId then
    if currentParentId then
      local siblings = self.childSets[currentParentId]
      siblings[entityId] = nil

      if not next(siblings) then
        self.childSets[currentParentId] = nil
      end
    end

    self.parents[entityId] = parentId

    if parentId then
      local siblings = self.childSets[parentId]

      if not siblings then
        siblings = {}
        self.childSets[parentId] = siblings
      end

      siblings[entityId] = true
    end

    self:clearDescendantWorldTransforms(entityId)
  end
end

function TransformSystem:getParameters(entityId)
  return unpack(self.parameterLists[entityId])
end

function TransformSystem:setParameters(
  entityId, x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY)

  local parameters = self.parameterLists[entityId]

  if not self.previousParameterLists[entityId] then
    self.previousParameterLists[entityId] = parameters
    parameters = self:allocateParameters()
    self.parameterLists[entityId] = parameters
  end

  parameters[1] = x or 0
  parameters[2] = y or 0
  parameters[3] = angle or 0
  parameters[4] = scaleX or 1
  parameters[5] = scaleY or 1
  parameters[6] = originX or 0
  parameters[7] = originY or 0
  parameters[8] = skewX or 0
  parameters[9] = skewY or 0

  local transform = self.transforms[entityId]

  transform:setTransformation(
    x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY)

  self:clearDescendantWorldTransforms(entityId)
end

function TransformSystem:getTransform(entityId)
  return self.transforms[entityId]
end

function TransformSystem:getWorldTransform(entityId)
  local worldTransform = self.worldTransforms[entityId]

  if not worldTransform then
    worldTransform = self:allocateTransform()
    self.worldTransforms[entityId] = worldTransform
    worldTransform:reset()
    local parentId = self.parents[entityId]

    if parentId then
      worldTransform:apply(self:getWorldTransform(parentId))
    end

    worldTransform:apply(self.transforms[entityId])
  end

  return worldTransform
end

function TransformSystem:getInterpolatedWorldTransform(entityId)
  local worldTransform = self.worldTransforms[entityId]

  if not worldTransform then
    worldTransform = self:allocateTransform()
    self.interpolatedWorldTransform[entityId] = worldTransform

    local parentId = self.parents[entityId]

    if parentId then
      worldTransform:apply(self:getInterpolatedWorldTransform(parentId))
    end

    -- TODO: Interpolate
    worldTransform:apply(self.transforms[entityId])
  end

  return worldTransform
end

function TransformSystem:allocateParameters()
  if #self.parameterListPool == 0 then
    return {0, 0, 0, 1, 1, 0, 0, 0, 0}
  end

  return table.remove(self.parameterListPool)
end

function TransformSystem:allocateTransform()
  if #self.transformPool == 0 then
    return love.math.newTransform()
  end

  return table.remove(self.transformPool)
end

function TransformSystem:clearDescendantWorldTransforms(entityId)
  local worldTransform = self.worldTransforms[entityId]

  if worldTransform then
    self.worldTransforms[entityId] = nil
    table.insert(self.transformPool, worldTransform)

    local children = self.childSets[entityId]

    if children then
      for childId in pairs(children) do
        self:clearDescendantWorldTransforms(childId)
      end
    end
  end
end

return TransformSystem
