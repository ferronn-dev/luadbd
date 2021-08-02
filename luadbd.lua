local lpeg = require('lpeg')

local lit = lpeg.P
local coltype = lit('int') + lit('string') + lit('float') + lit('locstring')
local sym = lpeg.R('az', 'AZ') * lpeg.R('az', 'AZ', '09')^0
local fkey = lit('<') * sym * lit('::') * sym * lit('>')
local skiptoeol = (1 - lpeg.S('\n'))^0
local commenteol = (lit(' // ') * skiptoeol)^-1 * lit('\n')
local column = lpeg.Ct(
    lpeg.Cg(lpeg.C(coltype), 'type') *
    fkey^-1 *
    lit(' ') *
    lpeg.Cg(sym, 'name') *
    lit('?')^-1 *
    commenteol)
local build = lit('BUILD ') * lpeg.C((lpeg.R('09') + lpeg.S('.-, '))^0) * lit('\n')
local buildcol = lpeg.Ct(lpeg.Cg(sym, 'name') * commenteol)
local version = lpeg.Ct(
    lit('\n') *
    lpeg.Cg(lit('LAYOUT ') * lpeg.C(lpeg.R('09', 'AF')^8) * lit('\n'), 'layout')^-1 *
    lpeg.Cg(lpeg.Ct(build^0), 'builds') *
    (lit('COMMENT ') * skiptoeol * lit('\n'))^-1 *
    lpeg.Cg(lpeg.Ct(buildcol^0), 'columns'))
local dbd = lpeg.Ct(
    lit('COLUMNS\n') *
    lpeg.Cg(lpeg.Ct(column^0), 'columns') *
    lpeg.Cg(lpeg.Ct(version^0), 'versions') *
    -lpeg.P(1))

local parse = function(s)
  return dbd:match(s)
end

return {
  parse = parse,
}
