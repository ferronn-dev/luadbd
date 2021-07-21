describe('luadbd', function()
  local parse = require('luadbd').parse
  it('fails on empty string', function()
    assert.Nil(parse(''))
  end)
  it('succeeds with no columns', function()
    assert.same(8, parse('COLUMNS'))
  end)
end)
