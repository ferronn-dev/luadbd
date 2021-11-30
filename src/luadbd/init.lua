local dbcsig = require('luadbd.sig').dbcsig
local dbd = require('luadbd.parser').dbd

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
