describe('luadbd', function()
  local parse = require('luadbd').parse
  it('fails on empty string', function()
    assert.Nil(parse(''))
  end)
  it('succeeds with no columns', function()
    local expected = {
      columns = {},
    }
    assert.same(expected, parse('COLUMNS'))
  end)
  it('succeeds with one int column', function()
    local expected = {
      columns = {
        { type = 'int', name = 'moocow' },
      },
    }
    assert.same(expected, parse('COLUMNS int moocow'))
  end)
end)
