local physics = {}

physics.BodyManager = require("heart.physics.BodyManager")
physics.CircleFixtureManager = require("heart.physics.CircleFixtureManager")
physics.MotorJointManager = require("heart.physics.MotorJointManager")
physics.PhysicsDebugSystem = require("heart.physics.PhysicsDebugSystem")
physics.PhysicsSystem = require("heart.physics.PhysicsSystem")
physics.PrismaticJointManager = require("heart.physics.PrismaticJointManager")

physics.RectangleFixtureManager =
    require("heart.physics.RectangleFixtureManager")

physics.RevoluteJointManager = require("heart.physics.RevoluteJointManager")

return physics
