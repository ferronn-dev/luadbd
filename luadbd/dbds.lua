local dbdMT = {
  __index = {
    dbcsig = require('luadbd.sig').dbcsig,
    rows = require('luadbd.dbcwrap'),
  }
}

local dbds = {}

do
  local dir = 'WoWDBDefs/definitions'
  local dbdparse = require('luadbd.parser').dbd
  for entry in require('lfs').dir(dir) do
    if entry:sub(-4) == '.dbd' then
      local tn = string.lower(entry:sub(1, -5))
      local f = assert(io.open(dir .. '/' .. entry, 'r'))
      local s = f:read('*a')
      f:close()
      local dbd = assert(dbdparse(s), 'failed to parse ' .. entry)
      dbds[tn] = setmetatable(dbd, dbdMT)
    end
  end
end

return dbds
