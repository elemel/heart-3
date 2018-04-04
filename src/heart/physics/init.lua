local physics = {}

physics.BodyComponentManager = require("heart.physics.BodyComponentManager")

physics.ChainFixtureComponentManager =
  require("heart.physics.ChainFixtureComponentManager")

physics.CircleFixtureComponentManager =
  require("heart.physics.CircleFixtureComponentManager")

physics.MotorJointComponentManager =
  require("heart.physics.MotorJointComponentManager")

physics.PhysicsDebugSystem = require("heart.physics.PhysicsDebugSystem")
physics.PhysicsSystem = require("heart.physics.PhysicsSystem")

physics.PolygonFixtureComponentManager =
    require("heart.physics.PolygonFixtureComponentManager")

physics.PrismaticJointComponentManager =
  require("heart.physics.PrismaticJointComponentManager")

physics.RectangleFixtureComponentManager =
    require("heart.physics.RectangleFixtureComponentManager")

physics.RevoluteJointComponentManager =
  require("heart.physics.RevoluteJointComponentManager")

return physics
