local transform = {}

transform.TransformComponentManager =
  require("heart.transform.TransformComponentManager")

transform.TransformDebugSystem = require("heart.transform.TransformDebugSystem")
transform.TransformSystem = require("heart.transform.TransformSystem")

return transform
