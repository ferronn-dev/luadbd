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

local dbds = loadstring(getCached('dbd.lua', function()
  local t = {}
  local tmpname = os.tmpname()
  local f = io.open(tmpname, 'w')
  f:write((fetchHttp('https://codeload.github.com/wowdev/WoWDBDefs/zip/refs/heads/master')))
  f:close()
  local dbdparse = require('luadbd.parser').dbd
  local z = require('zip').open(tmpname)
  for zz in z:files() do
    local tn = zz.filename:match('/definitions/(%a+).dbd')
    if tn then
      local zf = z:open(zz.filename)
      local dbd = assert(dbdparse(zf:read('*a')))
      zf:close()
      dbd.name = tn
      t[string.lower(tn)] = dbd
    end
  end
  z:close()
  os.remove(tmpname)
  return 'return ' .. inspect(t)
end))()

local ret = {}
for tn, dbd in pairs(dbds) do
  local fdid = db2s[tn]
  if fdid then
    dbd.fdid = fdid
    ret[tn] = setmetatable(dbd, dbdMT)
  end
end
return ret
