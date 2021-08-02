describe('luadbd', function()
  local parse = require('luadbd').parse
  it('fails on empty string', function()
    assert.Nil(parse(''))
  end)
  it('succeeds with no columns', function()
    local expected = {
      columns = {},
    }
    assert.same(expected, parse('COLUMNS\n'))
  end)
  it('succeeds with one int column', function()
    local expected = {
      columns = {
        { type = 'int', name = 'moocow' },
      },
    }
    assert.same(expected, parse('COLUMNS\nint moocow\n'))
  end)
  it('handles column comments', function()
    local expected = {
      columns = {
        { type = 'int', name = 'moocow' },
        { type = 'string', name = 'cowmoo' },
      },
    }
    assert.same(expected, parse([[
COLUMNS
int moocow // comment 1
string cowmoo // comment 2
]]))
  end)
end)
