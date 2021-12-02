local fetchHttp = require('ssl.https').request
local getCached = require('luadbd.cache').get
local inspect = require('inspect')

local dbdMT = {
  __index = {
    dbcsig = require('luadbd.sig').dbcsig,
    rows = require('luadbd.dbcwrap'),
  }
}

local db2s = loadstring(getCached('db2.lua', function()
  local t = {}
  local listfile = fetchHttp('https://wow.tools/casc/listfile/download/csv')
  for line in listfile:gmatch('[^\r\n]+') do
    local id, name = line:match('(%d+);dbfilesclient/([a-z0-9-_]+).db2')
    if id then
      t[name] = tonumber(id)
    end
  end
  return 'return ' .. inspect(t)
end))()

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
