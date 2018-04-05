return {
  components = {
    transform = {},

    body = {
      bodyType = "dynamic",
    },

    circleFixture = {
      radius = 17 / 32,
      restitution = 0.3,
    },
  },

  children = {
    {
      prototype = "resources.entities.fire",
    },
  },
}
