rockspec_format = '3.0'
package = 'luadbd'
version = 'scm-0'
description = {
  summary = 'WoWDBDefs parser',
  license = 'MIT',
  homepage = 'https://github.com/lua-wow-tools/luadbd',
  issues_url = 'https://github.com/lua-wow-tools/luadbd/issues',
  maintainer = 'ferronn@ferronn.dev',
  labels = {'wow'},
}
source = {
  url = 'https://github.com/lua-wow-tools/luadbd/archive/refs/tags/vscm.tar.gz',
  dir = 'luadbd-scm',
}
dependencies = {
  'lpeg',
}
build = {
  type = 'none',
  modules = {
    ['luadbd'] = 'luadbd.lua',
    ['luadbd.parser'] = 'luadbd/parser.lua',
    ['luadbd.sig'] = 'luadbd/sig.lua',
  },
}
