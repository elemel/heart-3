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
      maxMotorTorque = 50000,
    },

    flipper = {
      direction = -1,
      speed = 50,
    },

    hullFixtures = {
      circles = {
        0, 0, 1,
        6, 0, 0.5,
      },
    },
  },
}
