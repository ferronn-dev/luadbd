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

local function dbcsig(dbdef, version)
  return mksig(dbdef.columns, version.columns)
end

return dbcsig
