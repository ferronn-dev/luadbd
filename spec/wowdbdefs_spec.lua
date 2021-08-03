describe('luadbd wowdbdefs', function()
  local parse = require('luadbd').parse
  local dir = 'WoWDBDefs/definitions'
  for entry in require('lfs').dir(dir) do
    if entry:sub(-4) == '.dbd' then
      it('parses ' .. entry, function()
        local f = assert(io.open(dir .. '/' .. entry, 'r'))
        local s = f:read('*a')
        f:close()
        assert.Not.Nil(parse(s))
      end)
    end
  end
end)
