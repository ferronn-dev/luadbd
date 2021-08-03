return {
  parse = (function()
    local lpeg = require('lpeg')
    local C, Cg, Ct, P, R, S = lpeg.C, lpeg.Cg, lpeg.Ct, lpeg.P, lpeg.R, lpeg.S
    local coltype = P('int') + P('string') + P('float') + P('locstring')
    local sym = R('az', 'AZ') * R('az', 'AZ', '09', '__')^0
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
    local num = R('09')^1 / tonumber
    local onebuild = Ct(num * P('.') * num * P('.') * num * P('.') * num)
    local build = Ct(onebuild * (P('-') * onebuild)^-1)
    local buildline = P('BUILD ') * build * (P(', ') * build)^0 * P('\n')
    local anno = P('id') + P('relation') + P('noninline')
    local const = function(x) return function() return x end end
    local buildcol = Ct(
        Cg(P('$') * Ct(C(anno) * (P(',') * C(anno))^0) * P('$'), 'annotations')^-1 *
        Cg(sym, 'name') *
        (P('<') * Cg(P('u') / const(true), 'unsigned')^-1 * Cg(num, 'size') * P('>'))^-1 *
        (P('[') * Cg(num, 'length') * P(']'))^-1 *
        commenteol)
    local hash = R('09', 'AF')^8
    local version = Ct(
        P('\n') *
        Cg(P('LAYOUT ') * Ct(C(hash) * (P(', ') * C(hash))^0) * P('\n'), 'layout')^-1 *
        Cg(Ct(buildline^0), 'builds') *
        (P('COMMENT ') * skiptoeol * P('\n'))^-1 *
        Cg(Ct(buildcol^0), 'columns'))
    local dbd = Ct(
        P('COLUMNS\n') *
        Cg(Ct(column^0), 'columns') *
        Cg(Ct(version^0), 'versions') *
        -P(1))
    return function(s)
      return dbd:match(s)
    end
  end)(),
}
