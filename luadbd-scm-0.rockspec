rockspec_format = '3.0'
package = 'luadbd'
version = 'scm-0'
source = {
  url = 'git://github.com/ferronn-dev/luadbd',
}
dependencies = {
  'lpeg',
}
build = {
  type = 'none',
  modules = {
    ['luadbd'] = 'src/luadbd/init.lua',
    ['luadbd.parser'] = 'src/luadbd/parser.lua',
    ['luadbd.sig'] = 'src/luadbd/sig.lua',
  },
}
