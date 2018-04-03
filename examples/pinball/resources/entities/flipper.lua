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

    eggFixtures = {
      x1 = 0,
      y1 = 0,
      radius1 = 1,
      x2 = 4,
      y2 = 0,
      radius2 = 0.5,
    },
  },
}
