return {
  components = {
    transform = {},

    particleSystem = {
      image = "resources/images/pixel.png",
      blendMode = "add",
      emissionRate = 1000,
      particleLifetime = 0.2,

      sizes = {
        0.4,
      },

      emissionArea = {
        distribution = "normal",
        dx = 0.4,
        dy = 0.4,
      },

      minLinearDamping = 5,
      maxLinearDamping = 10,
      maxSpeed = 5,
      spread = 2 * math.pi,
      linearAccelerationY = -100,
      minRotation = -math.pi,
      maxRotation = math.pi,

      colors = {
        1, 1, 0.5, 0.5,
        1, 0.5, 0, 0.5,
        0.5, 0, 0, 0.5,
        0, 0, 0, 0.5,
      },
    },
  },
}
