local dbcrows = require('dbc').rows

local function rowsForBuild(version, data)
  local iterfn, iterdata = dbcrows(data, '{' .. version.sig .. '}')
  local function wrapfn(...)
    local t = iterfn(...)
    return t and setmetatable(t, version.rowMT) or nil
  end
  return wrapfn, iterdata
end

local function rowsForDBD(dbd, build, data)  -- TODO remove this
  local version = assert(
      dbd:build(build),
      ('no schema for dbd %s build %s'):format(dbd.name, build))
  return rowsForBuild(version, data)
end

return {
  build = rowsForBuild,
  dbd = rowsForDBD,
}
