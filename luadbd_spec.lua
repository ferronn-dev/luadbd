describe('luadbd', function()
  assert:set_parameter('TableFormatLevel', -1)
  local parse = require('luadbd').parse
  it('fails on empty string', function()
    assert.Nil(parse(''))
  end)
  it('succeeds with no columns', function()
    local expected = {
      columns = {},
      versions = {},
    }
    assert.same(expected, parse('COLUMNS\n'))
  end)
  it('succeeds with one int column', function()
    local expected = {
      columns = {
        { type = 'int', name = 'moocow' },
      },
      versions = {},
    }
    assert.same(expected, parse('COLUMNS\nint moocow\n'))
  end)
  it('handles column comments', function()
    local expected = {
      columns = {
        { type = 'int', name = 'moocow' },
        { type = 'string', name = 'cowmoo' },
      },
      versions = {},
    }
    assert.same(expected, parse([[
COLUMNS
int moocow // comment 1
string cowmoo // comment 2
]]))
  end)
  it('handles builds', function()
    local expected = {
      columns = {
        { type = 'string', name = 'cowmoo' },
      },
      versions = {
        {
          builds = {
            '7.2.0.23436-7.2.0.23514',
            '0.7.0.3694, 0.7.1.3702, 0.7.6.3712',
            '0.9.1.3810',
          },
          columns = {
            { name = 'cowmoo' },
          },
        },
      },
    }
    assert.same(expected, parse([[
COLUMNS
string cowmoo

BUILD 7.2.0.23436-7.2.0.23514
BUILD 0.7.0.3694, 0.7.1.3702, 0.7.6.3712
BUILD 0.9.1.3810
cowmoo
]]))
  end)
end)
