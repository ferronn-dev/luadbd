local dbds = {}

do
  local dir = 'WoWDBDefs/definitions'
  local dbdparse = require('luadbd').parse
  for entry in require('lfs').dir(dir) do
    if entry:sub(-4) == '.dbd' then
      local tn = string.lower(entry:sub(1, -5))
      local f = assert(io.open(dir .. '/' .. entry, 'r'))
      local s = f:read('*a')
      f:close()
      dbds[tn] = assert(dbdparse(s), 'failed to parse ' .. entry)
    end
  end
end

return dbds
