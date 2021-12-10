local onebuild = require('luadbd.parser').onebuild

local function bleq(a, b)
  if a[1] < b[1] then
    return true
  elseif a[1] > b[1] then
    return false
  elseif a[2] < b[2] then
    return true
  elseif a[2] > b[2] then
    return false
  elseif a[3] < b[3] then
    return true
  elseif a[3] > b[3] then
    return false
  else
    return a[4] <= b[4]
  end
end

local function inBuildRange(br, b)
  if #br == 1 then
    return bleq(br[1], b) and bleq(b, br[1])
  else
    return bleq(br[1], b) and bleq(b, br[2])
  end
end

local function getVersion(dbdef, build)
  local b = onebuild(build)
  for _, version in ipairs(dbdef.versions) do
    for _, br in ipairs(version.builds) do
      if inBuildRange(br, b) then
        return version
      end
    end
  end
  return nil
end

return getVersion
