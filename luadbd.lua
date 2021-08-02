local lpeg = require('lpeg')
local C, Cg, Ct, P, R, S = lpeg.C, lpeg.Cg, lpeg.Ct, lpeg.P, lpeg.R, lpeg.S

local coltype = P('int') + P('string') + P('float') + P('locstring')
local sym = R('az', 'AZ') * R('az', 'AZ', '09')^0
local fkey = P('<') * sym * P('::') * sym * P('>')
local skiptoeol = (1 - S('\n'))^0
local commenteol = (P(' // ') * skiptoeol)^-1 * P('\n')
local column = Ct(
    Cg(C(coltype), 'type') *
    fkey^-1 *
    P(' ') *
    Cg(sym, 'name') *
    P('?')^-1 *
    commenteol)
local build = P('BUILD ') * C((R('09') + S('.-, '))^0) * P('\n')
local buildcol = Ct(Cg(sym, 'name') * commenteol)
local version = Ct(
    P('\n') *
    Cg(P('LAYOUT ') * C(R('09', 'AF')^8) * P('\n'), 'layout')^-1 *
    Cg(Ct(build^0), 'builds') *
    (P('COMMENT ') * skiptoeol * P('\n'))^-1 *
    Cg(Ct(buildcol^0), 'columns'))
local dbd = Ct(
    P('COLUMNS\n') *
    Cg(Ct(column^0), 'columns') *
    Cg(Ct(version^0), 'versions') *
    -P(1))

local function parse(s)
  return dbd:match(s)
end

return {
  parse = parse,
}
