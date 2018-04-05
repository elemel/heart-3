local heart = require("heart")

function love.load()
  love.window.setTitle("Pinball")

  love.window.setMode(800, 600, {
    fullscreentype = "desktop",
    resizable = true,
    highdpi = true,
    msaa = 8,
    -- fullscreen = true,
  })

  love.mouse.setVisible(false)
  love.physics.setMeter(1)

  local gameContext = {
    systemClasses = {
      category = assert(heart.category.CategorySystem),
      fixedUpdate = assert(heart.update.FixedUpdateSystem),
      graphics = assert(heart.graphics.GraphicsSystem),
      physics = assert(heart.physics.PhysicsSystem),
      physicsDebug = assert(heart.physics.PhysicsDebugSystem),
      script = assert(heart.script.ScriptSystem),
      transform = assert(heart.math.TransformSystem),
      transformDebug = assert(heart.math.TransformDebugSystem),
      update = assert(heart.update.UpdateSystem),
    },
  }

  local gameConfig = require("resources.levels.test")
  game = heart.game.Game.new(gameContext, gameConfig)
end

function love.draw(...)
  game.topics.draw:publish(...)
end

function love.keypressed(...)
  game.topics.keypressed:publish(...)
end

function love.quit(...)
  game.topics.quit:publish(...)
end

function love.update(...)
  game.topics.update:publish(...)
end
