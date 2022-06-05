local dbcsig = require('luadbd.sig')
local fetchHttp = require('ssl.https').request
local getCached = require('luadbd.cache').get
local inspect = require('inspect')

local dbdMT = {
  __index = {
    build = require('luadbd.build'),
  },
}

local buildMT = {
  __index = {
    rows = require('luadbd.dbcwrap').build,
  },
}

local db2s = loadstring(getCached('db2.lua', function()
  local t = {}
  local listfile = fetchHttp('https://wow.tools/casc/listfile/download/csv/unverified')

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
  local z = require('brimworks.zip').open(tmpname)
  for i = 1, #z do
    local tn = z:get_name(i):match('/definitions/(%a+).dbd')
    if tn then
      local zf = z:open(i)
      local dbd = assert(dbdparse(zf:read(1e8)))
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
    for _, version in ipairs(dbd.versions) do
      local sig, fields = dbcsig(dbd, version)
      version.sig = sig
      version.fields = fields
      version.rowMT = {
        __index = function(t, k)
          local i = fields[k]
          return i and t[i] or nil
        end,
      }
      setmetatable(version, buildMT)
    end
  end
end
return ret
