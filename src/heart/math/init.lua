local mathUtils = require("heart.math.utils")

local heartMath = {}

for k, v in pairs(mathUtils) do
  heartMath[k] = v
end

heartMath.TransformComponentManager =
  require("heart.math.TransformComponentManager")

heartMath.TransformDebugSystem = require("heart.math.TransformDebugSystem")
heartMath.TransformSystem = require("heart.math.TransformSystem")

return heartMath
