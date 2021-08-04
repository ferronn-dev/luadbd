describe('luadbd wowdbdefs', function()
  local parse = require('luadbd').parse
  local dir = 'WoWDBDefs/definitions'
  for entry in require('lfs').dir(dir) do
    if entry:sub(-4) == '.dbd' then
      it('parses ' .. entry, function()
        local f = assert(io.open(dir .. '/' .. entry, 'r'))
        local s = f:read('*a')
        f:close()
        local dbd = parse(s)
        assert.Not.Nil(dbd)
        assert.True(pcall(function()
          dbd:dbcsig('9.1.0.38312')
        end))
      end)
    end
  end
end)
