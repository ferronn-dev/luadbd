local lfs = require('lfs')

local topLevelCacheDir = (function()
  for _, opener in ipairs(require('datafile').openers) do
    local dirs = opener.get_dirs('cache')
    for _, dir in ipairs(dirs or {}) do
      if lfs.attributes(dir, 'mode') == 'directory' then
        return dir
      end
    end
  end
end)()

local cacheDir = (function()
  if topLevelCacheDir then
    local dir = topLevelCacheDir .. '/luadbd'
    local mode = lfs.attributes(dir, 'mode')
    if not mode then
      lfs.mkdir(dir)
      mode = lfs.attributes(dir, 'mode')
    end
    return mode == 'directory' and dir or nil
  end
end)()

local function get(localname, fn)
  if cacheDir then
    local cacheFile = cacheDir .. '/' .. localname
    local attrs = lfs.attributes(cacheFile)
    if attrs.mode == 'file' and os.difftime(os.time(), attrs.modification) < 60 * 60 * 4 then
      local f = io.open(cacheFile, 'r')
      local content = f:read('*all')
      f:close()
      return content
    end
  end
  local content = fn()
  if cacheDir then
    local cacheFile = cacheDir .. '/' .. localname
    local f = io.open(cacheFile, 'w')
    f:write(content)
    f:close()
  end
  return content
end

return {
  get = get,
}
