local ParticleSystemComponentManager = {}
ParticleSystemComponentManager.__index = ParticleSystemComponentManager
ParticleSystemComponentManager.dependencies = {"transform"}

function ParticleSystemComponentManager.new(...)
  local instance = setmetatable({}, ParticleSystemComponentManager)
  instance:init(...)
  return instance
end

function ParticleSystemComponentManager:init(graphicsSystem)
  self.graphicsSystem = assert(graphicsSystem)
end

function ParticleSystemComponentManager:createComponent(entityId, config)
  local z = config.z or 0
  local blendMode = config.blendMode or "alpha"
  self.graphicsSystem.particleSystemZs[entityId] = z
  self.graphicsSystem.particleSystemBlendModes[entityId] = blendMode
  local layer = self.graphicsSystem:createLayer(z)
  local imageFilename = assert(config.image)
  local image = love.graphics.newImage(imageFilename)
  local bufferSize = config.bufferSize
  local particleSystem = love.graphics.newParticleSystem(image, bufferSize)
  local particleLifetime = config.particleLifetime or 1
  particleSystem:setParticleLifetime(particleLifetime)
  local emissionRate = config.emissionRate or 1
  particleSystem:setEmissionRate(emissionRate)

  if config.sizes then
    particleSystem:setSizes(unpack(config.sizes))
  end

  local minRotation = config.minRotation or config.rotation or 0
  local maxRotation = config.maxRotation or config.rotation or 0
  particleSystem:setRotation(minRotation, maxRotation)

  local minLinearAccelerationX =
      config.minLinearAccelerationX or config.linearAccelerationX or 0

  local minLinearAccelerationY =
      config.minLinearAccelerationY or config.linearAccelerationY or 0

  local maxLinearAccelerationX =
      config.maxLinearAccelerationX or config.linearAccelerationX or 0

  local maxLinearAccelerationY =
      config.maxLinearAccelerationY or config.linearAccelerationY or 0

  particleSystem:setLinearAcceleration(
      minLinearAccelerationX, minLinearAccelerationY,
      maxLinearAccelerationX, maxLinearAccelerationY)

  local minLinearDamping = config.minLinearDamping or config.linearDamping or 0
  local maxLinearDamping = config.maxLinearDamping or config.linearDamping or 0
  particleSystem:setLinearDamping(minLinearDamping, maxLinearDamping)

  local areaSpreadDistribution = config.areaSpreadDistribution or "none"

  local areaSpreadDistanceX =
      config.areaSpreadDistanceX or config.areaSpreadDistance or 0

  local areaSpreadDistanceY =
      config.areaSpreadDistanceY or config.areaSpreadDistance or 0

  particleSystem:setAreaSpread(
      areaSpreadDistribution, areaSpreadDistanceX, areaSpreadDistanceY)

  local minSpeed = config.minSpeed or config.speed or 0
  local maxSpeed = config.maxSpeed or config.speed or 0
  particleSystem:setSpeed(minSpeed, maxSpeed)

  local minSpeed = config.minSpeed or config.speed or 0
  local maxSpeed = config.maxSpeed or config.speed or 0
  particleSystem:setSpeed(minSpeed, maxSpeed)

  local spread = config.spread or 0
  particleSystem:setSpread(spread)

  if config.colors then
    particleSystem:setColors(unpack(config.colors))
  end

  layer.particleSystems[entityId] = particleSystem
  self.graphicsSystem.particleSystems[entityId] = particleSystem
end

function ParticleSystemComponentManager:destroyComponent(entityId)
  local z = assert(self.graphicsSystem.particleSystemZs[entityId])
  self.graphicsSystem.particleSystems[entityId] = nil
  self.graphicsSystem.particleSystemZs[entityId] = nil
  self.graphicsSystem.particleSystemBlendModes[entityId] = nil
  local layer = assert(self.graphicsSystem.layers[z])
  layer.particleSystems[entityId] = nil
end

return ParticleSystemComponentManager
