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
            { { 7, 2, 0, 23436 }, { 7, 2, 0, 23514 } },
            { { 0, 7, 0, 3694 } },
            { { 0, 7, 1, 3702 } },
            { { 0, 7, 6, 3712 } },
            { { 0, 9, 1, 3810 } },
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
          builds = {
            { { 0, 1, 2, 3 } },
          },
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
          builds = {
            { { 0, 1, 2, 3 } },
          },
          columns = {
            { name = 'cowmoo' },
          },
          layout = { 'DE4D8EEF' },
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

  it('handles build column annotations', function()
    local expected = {
      columns = {
        { type = 'int', name = 'moocow' },
      },
      versions = {
        {
          builds = {
            { { 0, 1, 2, 3 } },
          },
          columns = {
            { name = 'moocow', size = 8 },
            { name = 'moocow', size = 64, unsigned = true },
            { name = 'moocow', length = 42 },
            { name = 'moocow', size = 16, length = 2 },
            { name = 'moocow', annotations = { 'id' } },
            { name = 'moocow', length = 42, annotations = { 'id', 'noninline' } },
            { name = 'moocow', size = 32, annotations = { 'relation' } },
          },
        },
      },
    }
    assert.same(expected, parse([[
COLUMNS
int moocow

BUILD 0.1.2.3
moocow<8>
moocow<u64>
moocow[42]
moocow<16>[2]
$id$moocow
$id,noninline$moocow[42]
$relation$moocow<32>
]]))
  end)
end)
