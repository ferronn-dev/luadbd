local dbcrows = require('dbc').rows

local function rowsForBuild(version, data)
  if data:sub(1, 4) == 'WDC4' then
    data = 'WDC3' .. data:sub(5)
  end
  local iterfn, iterdata = dbcrows(data, '{' .. version.sig .. '}')
  local function wrapfn(...)
    local t = iterfn(...)
    return t and setmetatable(t, version.rowMT) or nil
  end
  return wrapfn, iterdata
end

return {
  build = rowsForBuild,
}
