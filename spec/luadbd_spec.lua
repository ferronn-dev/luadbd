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

  it('handles build column comments', function()
    local expected = {
      columns = {
        { type = 'string', name = 'cowmoo' },
      },
      versions = {
        {
          builds = { '0.1.2.3' },
          columns = {
            { name = 'cowmoo' },
            { name = 'cowmoo' },
          },
        },
      },
    }
    assert.same(expected, parse([[
COLUMNS
string cowmoo

BUILD 0.1.2.3
cowmoo // This is a comment.
cowmoo // This is also a comment.
]]))
  end)

  it('handles layout and version comments', function()
    local expected = {
      columns = {
        { type = 'string', name = 'cowmoo' },
      },
      versions = {
        {
          builds = { '0.1.2.3' },
          columns = {
            { name = 'cowmoo' },
          },
          layout = 'DE4D8EEF',
        },
      },
    }
    assert.same(expected, parse([[
COLUMNS
string cowmoo

LAYOUT DE4D8EEF
BUILD 0.1.2.3
COMMENT roflcopter
cowmoo
]]))
  end)
end)
