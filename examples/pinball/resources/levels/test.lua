return {
  topics = {
    "draw",
    "keypressed",
    "quit",
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
    -- transformDebug = {},

    physics = {
      gravityX = 0,
      gravityY = 50,
    },

    physicsDebug = {
      colors = {
        fixture = {0, 1, 0, 1},
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
      scripts = {
        curveFixture = "resources.scripts.CurveFixture",
        flipper = "resources.scripts.Flipper",
        hullFixtures = "resources.scripts.HullFixtures",
      },
    },
  },

  entities = {
    {
      components = {
        transform = {},

        camera = {
          scale = 0.02,
        },
      },
    },

    {
      components = {
        transform = {},
        body = {},
      },

      children = {
        {
          prototype = "resources.entities.flipper",

          components = {
            transform = {
              x = -8,
              y = 16,
            },

            flipper = {
              key = "lshift",
              direction = -1,
            },
          },
        },

        {
          prototype = "resources.entities.flipper",

          components = {
            transform = {
              x = 8,
              y = 16,
              angle = math.pi,
            },

            revoluteJoint = {
              referenceAngle = -math.pi,
            },

            flipper = {
              key = "rshift",
              direction = 1,
            },
          },
        },

        {
          components = {
            transform = {},

            curveFixture = {
              controlPoints = {
                -25.7175, 0,
                -25.7175, -18,
                0, -18,
              },
            },
          },
        },

        {
          components = {
            transform = {},

            curveFixture = {
              controlPoints = {
                25.7175, 0,
                25.7175, -18,
                0, -18,
              },
            },
          },
        },

        {
          components = {
            transform = {},

            curveFixture = {
              controlPoints = {
                -25.7175, 0,
                -25.7175, 10,
                -8, 15,
              },
            },
          },
        },

        {
          components = {
            transform = {},

            curveFixture = {
              controlPoints = {
                25.7175, 0,
                25.7175, 10,
                8, 15,
              },
            },
          },
        },
      },
    },

    {
      prototype = "resources.entities.ball",

      components = {
        transform = {
          x = -5,
        },
      },
    },
  },
}
