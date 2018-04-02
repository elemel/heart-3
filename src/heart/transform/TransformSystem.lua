local mathUtils = require("heart.math.utils")
local SkeletonLoader = require("heart.transform.SkeletonLoader")
local SkeletonManager = require("heart.transform.SkeletonManager")
local TransformManager = require("heart.transform.TransformManager")
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
  self.previousXs = {}
  self.previousYs = {}
  self.previousAngles = {}
  self.previousWorldXs = {}
  self.previousWorldYs = {}
  self.previousWorldAngles = {}
  self.xs = setmetatable({}, {__index = self.previousXs})
  self.ys = setmetatable({}, {__index = self.previousYs})
  self.angles = setmetatable({}, {__index = self.previousAngles})
  self.worldXs = setmetatable({}, {__index = self.previousWorldXs})
  self.worldYs = setmetatable({}, {__index = self.previousWorldYs})
  self.worldAngles = setmetatable({}, {__index = self.previousWorldAngles})
  self.modes = {}
  self.dirty = {}
  self.parents = {}
  self.children = {}
  self.skeletonLoader = SkeletonLoader.new()
  self.game.componentManagers.skeleton = SkeletonManager.new(self)
  self.game.componentManagers.transform = TransformManager.new(self)
  self.fixedUpdateSystem = assert(self.game.systems.fixedUpdate)
  self.fixedUpdateSystem.topics.physics:subscribe(self, self.fixedUpdate)
end

function TransformSystem:fixedUpdate(dt)
  while true do
    local entityId = next(self.dirty)

    if not entityId then
      break
    end

    self:setDirty(entityId, false)
  end

  self:movePairs(self.xs, self.previousXs)
  self:movePairs(self.ys, self.previousYs)
  self:movePairs(self.angles, self.previousAngles)
  self:movePairs(self.worldXs, self.previousWorldXs)
  self:movePairs(self.worldYs, self.previousWorldYs)
  self:movePairs(self.worldAngles, self.previousWorldAngles)
end

function TransformSystem:movePairs(source, target)
  while true do
    local key, value = next(source)

    if key == nil then
      return
    end

    source[key] = nil
    target[key] = value
  end
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
  local currentParentId = self.parents[entityId]

  if parentId ~= currentParentId then
    local currentMode

    if mode then
      assert(mode == "local" or mode == "world")
      currentMode = self.modes[entityId]
      self:setMode(entityId, mode)
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

    self:setDirty(entityId, true)

    if mode then
      self:setMode(entityId, currentMode)
    end
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
      local parentId = self.parents[entityId]

      if parentId then
        self:setDirty(parentId, false)
      end

      local mode = self.modes[entityId]

      if mode == "local" then
        local x = self.xs[entityId]
        local y = self.ys[entityId]
        local angle = self.angles[entityId]

        if parentId then
          local parentX = self.worldXs[parentId]
          local parentY = self.worldYs[parentId]
          local parentAngle = self.worldAngles[parentId]

          x, y, angle =
            mathUtils.toWorldTransform2(
              x, y, angle, parentX, parentY, parentAngle)
        end

        self.worldXs[entityId] = x
        self.worldYs[entityId] = y
        self.worldAngles[entityId] = angle
      else
        local x = self.worldXs[entityId]
        local y = self.worldYs[entityId]
        local angle = self.worldAngles[entityId]

        if parentId then
          local parentX = self.worldXs[parentId]
          local parentY = self.worldYs[parentId]
          local parentAngle = self.worldAngles[parentId]

          x, y, angle =
            mathUtils.toLocalTransform2(
              x, y, angle, parentX, parentY, parentAngle)
        end

        self.xs[entityId] = x
        self.ys[entityId] = y
        self.angles[entityId] = angle
      end

      self.dirty[entityId] = nil
    end
  end
end

function TransformSystem:getTransform(entityId, t)
  if self.modes[entityId] ~= "local" then
    self:setDirty(entityId, false)
  end

  if not t then
    return self.xs[entityId], self.ys[entityId], self.angles[entityId]
  end

  local mixedX = mathUtils.mix(self.previousXs[entityId], self.xs[entityId], t)
  local mixedY = mathUtils.mix(self.previousYs[entityId], self.ys[entityId], t)

  local mixedAngle =
    mathUtils.mixAngles(self.previousAngles[entityId], self.angles[entityId], t)

  return mixedX, mixedY, mixedAngle
end

function TransformSystem:setTransform(entityId, x, y, angle)
  self:setMode(entityId, "local")

  if x ~= self.xs[entityId] or
    y ~= self.ys[entityId] or
    angle ~= self.angles[entityId] then

    self.xs[entityId] = x
    self.ys[entityId] = y
    self.angles[entityId] = angle
    self:setDirty(entityId, true)
  end
end

function TransformSystem:getWorldTransform(entityId, t)
  if self.modes[entityId] ~= "world" then
    self:setDirty(entityId, false)
  end

  if not t then
    return self.worldXs[entityId],
      self.worldYs[entityId],
      self.worldAngles[entityId]
  end

  local mixedX =
    mathUtils.mix(self.previousWorldXs[entityId], self.worldXs[entityId], t)

  local mixedY =
    mathUtils.mix(self.previousWorldYs[entityId], self.worldYs[entityId], t)

  local mixedAngle =
    mathUtils.mixAngles(
      self.previousWorldAngles[entityId], self.worldAngles[entityId], t)

  return mixedX, mixedY, mixedAngle
end

function TransformSystem:setWorldTransform(entityId, x, y, angle)
  self:setMode(entityId, "world")

  if x ~= self.worldXs[entityId] or
    y ~= self.worldYs[entityId] or
    angle ~= self.worldAngles[entityId] then

    self.worldXs[entityId] = x
    self.worldYs[entityId] = y
    self.worldAngles[entityId] = angle
    self:setDirty(entityId, true)
  end
end

return TransformSystem
