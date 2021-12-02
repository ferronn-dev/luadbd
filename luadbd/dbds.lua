local dbdMT = {
  __index = {
    dbcsig = require('luadbd.sig').dbcsig,
    rows = require('luadbd.dbcwrap'),
  }
}

local db2s = {}
for line in io.lines('db2.txt') do
  local id, name = line:match('(%d+);dbfilesclient/([a-z0-9-_]+).db2')
  assert(id, line)
  db2s[name] = tonumber(id)
end

local dbds = {}

do
  local dir = 'WoWDBDefs/definitions'
  local dbdparse = require('luadbd.parser').dbd
  for entry in require('lfs').dir(dir) do
    if entry:sub(-4) == '.dbd' then
      local tn = entry:sub(1, -5)
      local ltn = string.lower(tn)
      local fdid = db2s[ltn]
      if fdid then
        local f = assert(io.open(dir .. '/' .. entry, 'r'))
        local s = f:read('*a')
        f:close()
        local dbd = assert(dbdparse(s), 'failed to parse ' .. entry)
        dbd.name = tn
        dbd.fdid = fdid
        dbds[ltn] = setmetatable(dbd, dbdMT)
        end
    end
  end
end

return dbds
