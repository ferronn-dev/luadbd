local dbd, onebuild = (function()
  local lpeg = require('lpeg')
  local C, Cg, Ct, P, R, S = lpeg.C, lpeg.Cg, lpeg.Ct, lpeg.P, lpeg.R, lpeg.S
  local coltype = P('int') + P('string') + P('float') + P('locstring')
  local sym = R('az', 'AZ') * R('az', 'AZ', '09', '__')^0
  local fkey = P('<') * sym * P('::') * sym * P('>')
  local skiptoeol = (1 - S('\n'))^0
  local commenteol = (P(' // ') * skiptoeol)^-1 * P('\n')
  local column = Ct(
      Cg(C(coltype), 'type') *
      fkey^-1 *
      P(' ') *
      Cg(sym, 'name') *
      P('?')^-1 *
      commenteol)
  local num = R('09')^1 / tonumber
  local onebuild = Ct(num * P('.') * num * P('.') * num * P('.') * num)
  local build = Ct(onebuild * (P('-') * onebuild)^-1)
  local buildline = P('BUILD ') * build * (P(', ') * build)^0 * P('\n')
  local anno = P('id') + P('relation') + P('noninline')
  local const = function(x) return function() return x end end
  local buildcol = Ct(
      Cg(P('$') * Ct(C(anno) * (P(',') * C(anno))^0) * P('$'), 'annotations')^-1 *
      Cg(sym, 'name') *
      (P('<') * Cg(P('u') / const(true), 'unsigned')^-1 * Cg(num, 'size') * P('>'))^-1 *
      (P('[') * Cg(num, 'length') * P(']'))^-1 *
      commenteol)
  local hash = R('09', 'AF')^8
  local version = Ct(
      P('\n') *
      Cg(P('LAYOUT ') * Ct(C(hash) * (P(', ') * C(hash))^0) * P('\n'), 'layout')^-1 *
      Cg(Ct(buildline^0), 'builds') *
      (P('COMMENT ') * skiptoeol * P('\n'))^-1 *
      Cg(Ct(buildcol^0), 'columns'))
  local dbd = Ct(
      P('COLUMNS\n') *
      Cg(Ct(column^0), 'columns') *
      Cg(Ct(version^0), 'versions') *
      -P(1))
  return dbd, onebuild
end)()

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
  elseif not col.unsigned then
    return 'i'
  elseif col.size == 64 then
    return 'L'
  else
    return 'u'
  end
end

local function mksig(dcols, bcols)
  local types = {}
  for _, dc in ipairs(dcols) do
    types[dc.name] = dc.type
  end
  local sig = ''
  for _, bc in ipairs(bcols) do
    sig = sig .. string.rep(colsig(bc, types[bc.name]), bc.length or 1)
  end
  return sig
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

local dbdMT = {
  __index = {
    dbcsig = dbcsig,
  }
}

local function parse(s)
  local m = dbd:match(s)
  return m and setmetatable(m, dbdMT) or nil
end

return {
  parse = parse,
}
