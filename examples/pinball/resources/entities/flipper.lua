return {
  components = {
    transform = {},

    body = {
      bodyType = "dynamic",
    },

    revoluteJoint = {
      limitsEnabled = true,
      lowerLimit = -0.125 * math.pi,
      upperLimit = 0.125 * math.pi,
      motorEnabled = true,
      maxMotorTorque = 5000,
    },

    flipper = {
      direction = -1,
      speed = 100,
    },

    hullFixtures = {
      circles = {
        0, 0, 1,
        4, 0, 0.5,
      },
    },
  },
}
