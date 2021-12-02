local dbcrows = require('dbc').rows
local dbcsig = require('luadbd.sig').dbcsig

local function wrap(dbd, version, data)
  local sig, mt = dbcsig(dbd, version)
  assert(sig, 'no sig for ' .. version)
  local iterfn, iterdata = dbcrows(data, '{' .. sig .. '}')
  local function wrapfn(...)
    local t = iterfn(...)
    return t and setmetatable(t, mt) or nil
  end
  return wrapfn, iterdata
end

return wrap
