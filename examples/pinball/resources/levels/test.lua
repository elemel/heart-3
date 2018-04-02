return {
  topics = {
    "draw",
    "keypressed",
    "update",
  },

  systems = {
    category = {
      categories = {},
    },

    fixedUpdate = {
      fixedDt = 1 / 60,

      topics = {
        "transform",
        "input",
        "physics",
        "death",
      },
    },

    graphics = {
      topics = {
        "debug",
      },
    },

    transform = {},
    transformDebug = {},

    physics = {
      gravityX = 0,
      gravityY = 20,
    },

    physicsDebug = {
      colors = {
        fixture = {0x00, 0xff, 0x00, 0xff},
      },
    },

    update = {
      topics = {
        "fixedUpdate",
        "physics",
        "graphics",
      },
    },

    script = {
      scripts = {},
    },
  },

  entities = {
    {
      components = {
        transform = {},

        camera = {
          scale = 1 / 20,
        },
      },
    },

    {
      components = {
        transform = {},

        body = {
          bodyType = "dynamic",
        },

        circleFixture = {},
      },
    },
  },
}
