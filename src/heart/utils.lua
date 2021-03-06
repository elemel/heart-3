local utils = {}

function utils.index(t, v)
  for i = 1, #t do
    if t[i] == v then
      return i
    end
  end

  return nil
end

function utils.clear(t)
  for k, v in pairs(t) do
    t[k] = nil
  end
end

function utils.keys(t, keys)
  keys = keys or {}

  for k in pairs(t) do
    table.insert(keys, k)
  end

  return keys
end

function utils.values(t, values)
  values = values or {}

  for _, v in pairs(t) do
    table.insert(values, v)
  end

  return values
end

function utils.reverse(t)
    local i, j = 1, #t

    while i < j do
        t[i], t[j] = t[j], t[i]
        i = i + 1
        j = j - 1
    end
end

function utils.invert(t)
  local inverse = {}

  for k, v in pairs(t) do
    assert(not inverse[v])
    inverse[v] = k
  end

  return inverse
end

function utils.replace(t, source, target)
  local n = 0

  for k, v in pairs(t) do
    if v == source then
      t[k] = target
      n = n + 1
    end
  end

  return n
end

function utils.removeValue(t, v)
  for i = 1, #t do
    if t[i] == v then
      table.remove(t, i)
      return i
    end
  end

  return nil
end

function utils.removeLastValue(t, v)
  for i = #t, 1, -1 do
    if t[i] == v then
      table.remove(t, i)
      return i
    end
  end

  return nil
end

function utils.removeValues(t, v)
  local n = 0

  for i = 1, #t do
    if t[i] ~= v then
      n = n + 1
      t[n] = t[i]
    end
  end

  while #t > n do
    table.remove(t)
  end
end

function utils.replaceLastValue(t, source, target)
  for i = #t, 1, -1 do
    if t[i] == source then
      t[i] = target
      return i
    end
  end

  return nil
end

function utils.maxPathLengths(dag)
  local lengths = {}

  local function dfs(u)
    local length = lengths[u]

    if length then
      if length < 0 then
        error("Cyclic graph")
      end

      return length
    end

    lengths[u] = -1
    length = 0
    local vs = dag[u]

    if vs then
      for i, v in ipairs(vs) do
        length = math.max(length, dfs(v) + 1)
      end
    end

    lengths[u] = length
    return length
  end

  for u in pairs(dag) do
    dfs(u)
  end

  return lengths
end

function utils.topologicalOrdering(dag, reversed, tiebreaker)
  reversed = reversed == true

  tiebreaker = tiebreaker or function(a, b)
    return a < b
  end

  local lengths = utils.maxPathLengths(dag)
  local ordering = utils.keys(lengths)

  table.sort(ordering, function(u1, u2)
    local length1, length2 = lengths[u1], lengths[u2]

    if length1 ~= length2 then
      return (length1 > length2) ~= reversed
    end

    return tiebreaker(u1, u2)
  end)

  return ordering
end

-- https://en.wikipedia.org/wiki/Tangent_lines_to_circles#Outer_tangent
function utils.circlesTangent(x1, y1, radius1, x2, y2, radius2)
  local gamma = math.atan2(y2 - y1, x1 - x2)

  local beta =
    math.asin((radius1 - radius2) / math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2))

  local alpha = gamma - beta
  local x3 = x1 + radius1 * math.cos(0.5 * math.pi - alpha)
  local y3 = y1 + radius1 * math.sin(0.5 * math.pi - alpha)
  local x4 = x2 + radius2 * math.cos(0.5 * math.pi - alpha)
  local y4 = y2 + radius2 * math.sin(0.5 * math.pi - alpha)
  return x3, y3, x4, y4
end

return utils
