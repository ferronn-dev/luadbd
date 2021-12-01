local onebuild = require('luadbd.parser').onebuild

local function bleq(a, b)
  if a[1] < b[1] then
    return true
  elseif a[1] > b[1] then
    return false
  elseif a[2] < b[2] then
    return true
  elseif a[2] > b[2] then
    return false
  elseif a[3] < b[3] then
    return true
  elseif a[3] > b[3] then
    return false
  else
    return a[4] <= b[4]
  end
end

local function inBuildRange(br, b)
  if #br == 1 then
    return bleq(br[1], b) and bleq(b, br[1])
  else
    return bleq(br[1], b) and bleq(b, br[2])
  end
end

local function colsig(col, ty)
  if ty == 'string' or ty == 'locstring' then
    return 's'
  elseif ty == 'float' then
    return 'f'
  elseif col.size == 64 then
    return 'L'
  elseif col.unsigned then
    return 'u'
  else
    return 'i'
  end
end

local function mksig(dcols, bcols)
  local types = {}
  for _, dc in ipairs(dcols) do
    types[dc.name] = dc.type
  end
  local sig = ''
  local fields = {}
  local idx = 1
  for _, bc in ipairs(bcols) do
    local isID = false
    local isInline = true
    local isRelation = false
    if bc.annotations then
      for _, a in ipairs(bc.annotations) do
        isID = isID or a == 'id'
        isInline = isInline and a ~= 'noninline'
        isRelation = isRelation or a == 'relation'
      end
    end
    if isInline then
      local cs = colsig(bc, types[bc.name])
      if bc.length then
        cs = '{' .. bc.length .. cs .. '}'
      end
      sig = sig .. cs
      fields[bc.name] = idx
      idx = idx + 1
    elseif isRelation then
      sig = sig .. 'F'
      fields[bc.name] = idx
      idx = idx + 1
    elseif isID then
      fields[bc.name] = 0
    else
      error('invalid column')
    end
  end
  return sig, {
    __index = function(t, k)
      local i = fields[k]
      return i and t[i] or nil
    end,
  }
end

local function dbcsig(dbdef, build)
  local b = onebuild:match(build)
  for _, version in ipairs(dbdef.versions) do
    for _, br in ipairs(version.builds) do
      if inBuildRange(br, b) then
        return mksig(dbdef.columns, version.columns)
      end
    end
  end
  return nil
end

return {
  dbcsig = dbcsig,
}
