local product = arg[1] or 'wow'
local dbtoexport = arg[2]
local fieldstoexport = {select(3, unpack(arg))}

local db2s = {}
local ndb2s = 0
for line in io.lines('db2.txt') do
  local id, name = line:match('(%d+);dbfilesclient/([a-z0-9-_]+).db2')
  assert(id, line)
  db2s[name] = tonumber(id)
  ndb2s = ndb2s + 1
end
print('loaded ' .. ndb2s .. ' db2 names')

local handle, version = (function()
  local casc = require('casc')
  local url = 'http://us.patch.battle.net:1119/' .. product
  local bkey, cdn, ckey, version = casc.cdnbuild(url, 'us')
  assert(bkey)
  print('loading ' .. version)
  local handle = casc.open({
    bkey = bkey,
    cache = 'cache',
    cacheFiles = true,
    cdn = cdn,
    ckey = ckey,
    locale = casc.locale.US,
    log = print,
  })
  return handle, version
end)()

local sigs = {}
local mts = {}
local dir = 'WoWDBDefs/definitions'
for entry in require('lfs').dir(dir) do
  if entry:sub(-4) == '.dbd' then
    local f = assert(io.open(dir .. '/' .. entry, 'r'))
    local s = f:read('*a')
    f:close()
    local dbd = assert(require('luadbd').parse(s))
    local sig, mt = dbd:dbcsig(version)
    local tn = string.lower(entry:sub(1, -5))
    if not sig then
      print('no sig for ' .. tn)
    elseif not db2s[tn] then
      print('no datafileid for ' .. tn)
    else
      sigs[tn] = sig
      mts[tn] = mt
    end
  end
end

local function process(tn, cb)
  local sig = sigs[tn]
  local mt = mts[tn]
  local dfid = db2s[tn]
  if not sig or not mt or not dfid then
    print('cannot process ' .. tn)
    return
  end
  local data = handle:readFile(dfid)
  if not data then
    print('no data for ' .. tn)
    return
  end
  print('reading '.. tn .. ':' .. sig .. ':' .. dfid)
  local success, iterfn, iterdata = pcall(function()
    return require('dbc').rows(data, '{'..sig..'}')
  end)
  if not success then
    print('failed to get row iterator on ' .. tn .. ': ' .. iterfn)
    return
  end
  local itersuccess, err = pcall(function()
    local rows = 0
    for t in iterfn, iterdata do
      rows = rows + 1
      setmetatable(t, mt)
      cb(t)
    end
    print(rows .. ' rows')
  end)
  if not itersuccess then
    print('failed to iterate through ' .. tn .. ': ' .. err)
    return
  end
end

if dbtoexport then
  process(dbtoexport, function(t)
    for _, f in ipairs(fieldstoexport) do
      print(f .. ' = ' .. t[f])
    end
    print()
  end)
else
  for tn in pairs(sigs) do
    process(tn, function() end)
  end
end
