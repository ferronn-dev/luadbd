local product = arg[1] or 'wow'
local dbtoexport = arg[2]

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

local dbds = require('luadbd').dbds

local function process(dbd, cb)
  local tn = dbd.name
  local data = handle:readFile(dbd.fdid)
  if not data then
    print('no data for ' .. tn)
    return
  end
  local build = dbd:build(version)
  if not build then
    print('no build for ' .. tn)
    return
  end
  print('reading '.. tn .. ':' .. build.sig .. ':' .. dbd.fdid)
  local success, iterfn, iterdata = pcall(function()
    return build:rows(data)
  end)
  if not success then
    print('failed to get row iterator on ' .. tn .. ': ' .. iterfn)
    return
  end
  local itersuccess, err = pcall(function()
    local rows = 0
    for t in iterfn, iterdata do
      rows = rows + 1
      cb(build.fields, t)
    end
    print(rows .. ' rows')
  end)
  if not itersuccess then
    print('failed to iterate through ' .. tn .. ': ' .. err)
    return
  end
end

if dbtoexport then
  process(dbds[dbtoexport], function(fields, t)
    local toprint = {}
    for f, i in pairs(fields) do
      toprint[f] = t[i]
    end
    require('pl.pretty').dump(toprint)
  end)
else
  for _, dbd in pairs(dbds) do
    process(dbd, function() end)
  end
end
