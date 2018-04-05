local CameraComponentManager = require("heart.graphics.CameraComponentManager")
local heartMath = require("heart.math")
local MeshLoader = require("heart.graphics.MeshLoader")
local MeshComponentManager = require("heart.graphics.MeshComponentManager")

local ParticleSystemComponentManager =
    require("heart.graphics.ParticleSystemComponentManager")

local SpriteComponentManager = require("heart.graphics.SpriteComponentManager")
local Topic = require("heart.event.Topic")
local utils = require("heart.utils")

local GraphicsSystem = {}
GraphicsSystem.__index = GraphicsSystem
GraphicsSystem.dependencies = {"transform"}

function GraphicsSystem.new(...)
  local instance = setmetatable({}, GraphicsSystem)
  instance:init(...)
  return instance
end

function GraphicsSystem:init(game, config)
  self.game = assert(game)
  self.game.topics.draw:subscribe(self, self.draw)
  self.updateSystem = assert(self.game.systems.update)
  self.updateSystem.topics.graphics:subscribe(self, self.update)
  self.fixedUpdateSystem = assert(self.game.systems.fixedUpdate)
  self.transformSystem = assert(self.game.systems.transform)
  self.texelScale = config.texelScale or 1
  self.cameraAngles = {}
  self.cameraScales = {}
  self.topics = {}
  self.meshZs = {}
  self.spriteZs = {}
  self.spriteScaleXs = {}
  self.spriteScaleYs = {}
  self.spriteAlignmentXs = {}
  self.spriteAlignmentYs = {}
  self.particleSystems = {}
  self.particleSystemZs = {}
  self.particleSystemBlendModes = {}
  self.layers = {}
  self.minLayerZ = 0
  self.maxLayerZ = 0
  self.meshLoader = MeshLoader.new()

  local pixelShaderCode = [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 texcolor = Texel(texture, texture_coords);
      return texcolor * color;
    }
  ]]

  local vertexShaderCode = [[
    uniform mat4 inverseBindPoseTransforms[1];
    uniform mat4 boneTransforms[1];

    attribute float BoneIndex;

    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
      int i = int(BoneIndex);
      mat4 transform = boneTransforms[i] * inverseBindPoseTransforms[i];
      return transform_projection * transform * vertex_position;
    }
  ]]

  self.shader = love.graphics.newShader(pixelShaderCode, vertexShaderCode)

  if config.topics then
    for i, topicName in ipairs(config.topics) do
      local topic = Topic.new()
      table.insert(self.topics, topic)
      self.topics[topicName] = topic
    end
  end

  self.game.componentManagers.camera = CameraComponentManager.new(self)
  self.game.componentManagers.mesh = MeshComponentManager.new(self)
  self.game.componentManagers.sprite = SpriteComponentManager.new(self)

  self.game.componentManagers.particleSystem =
    ParticleSystemComponentManager.new(self)
end

function GraphicsSystem:update(dt)
  local fixedUpdateSystem = self.fixedUpdateSystem
  local transformSystem = self.transformSystem
  local t = fixedUpdateSystem.accumulatedDt / fixedUpdateSystem.fixedDt

  for entityId, particleSystem in pairs(self.particleSystems) do
    local transform = transformSystem:getWorldTransform(entityId, t)
    local x, y = transform:transformPoint(0, 0)
    particleSystem:setPosition(x, y)
    particleSystem:update(dt)
  end
end

function GraphicsSystem:draw()
  local fixedUpdateSystem = self.fixedUpdateSystem
  local transformSystem = self.transformSystem
  local t = fixedUpdateSystem.accumulatedDt / fixedUpdateSystem.fixedDt

  local viewportWidth, viewportHeight = love.graphics.getDimensions()
  local viewportScale = math.sqrt(viewportWidth * viewportHeight)

  for cameraEntityId, cameraScale in pairs(self.cameraScales) do
    local cameraTransform = transformSystem:getWorldTransform(cameraEntityId, t)
    local cameraX, cameraY, cameraAngle = heartMath.decompose2(cameraTransform)

    cameraAngle = self.cameraAngles[cameraEntityId] or cameraAngle
    local scale = viewportScale * cameraScale
    love.graphics.reset()
    love.graphics.translate(0.5 * viewportWidth, 0.5 * viewportHeight)
    love.graphics.scale(scale)
    love.graphics.rotate(-cameraAngle)
    love.graphics.translate(-cameraX, -cameraY)
    love.graphics.setLineWidth(1 / scale)

    for z = self.minLayerZ, self.maxLayerZ do
      local layer = self.layers[z]

      if layer then
        love.graphics.setShader(self.shader)

        for meshId, mesh in pairs(layer.meshes) do
          local meshX, meshY, meshAngle =
            transformSystem:getWorldTransform(meshId, t)

          self.shader:send("inverseBindPoseTransforms", {
              1, 0, 0, 0,
              0, 1, 0, 0,
              0, 0, 1, 0,
              0, 0, 0, 1,
          })

          self.shader:send("boneTransforms", {
              0.001, 0, 0, 0,
              0, 0.001, 0, 0,
              0, 0, 1, 0,
              meshX, meshY, 0, 1,
          })

          love.graphics.draw(mesh)
        end

        love.graphics.setShader(nil)

        for spriteId, image in pairs(layer.spriteImages) do
          local transform = transformSystem:getWorldTransform(spriteId, t)
          love.graphics.draw(image, transform)
        end

        for entityId, particleSystem in pairs(layer.particleSystems) do
          local blendMode = self.particleSystemBlendModes[entityId]
          love.graphics.setBlendMode(blendMode)
          love.graphics.draw(particleSystem)
        end

        love.graphics.setBlendMode("alpha")
      end
    end

    for j, topic in ipairs(self.topics) do
      topic:publish()
    end
  end
end

function GraphicsSystem:createLayer(z)
  local layer = self.layers[z]

  if not layer then
    layer = {
      meshes = {},
      spriteImages = {},
      particleSystems = {},
    }

    self.layers[z] = layer
    self.minLayerZ = math.min(self.minLayerZ, z)
    self.maxLayerZ = math.max(self.maxLayerZ, z)
  end

  return layer
end

return GraphicsSystem
