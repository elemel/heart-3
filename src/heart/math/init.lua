local mathUtils = require("heart.math.utils")

local heartMath = {}

heartMath.Matrix = require("heart.math.Matrix")

for k, v in pairs(mathUtils) do
  heartMath[k] = v
end

return heartMath
