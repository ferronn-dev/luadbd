local lpeg = require('lpeg')

local lit = lpeg.P
local coltype = lit('int') + lit('string') + lit('float') + lit('locstring')
local sym = lpeg.R('az', 'AZ') * lpeg.R('az', 'AZ', '09')^0
local fkey = lit('<') * sym * lit('::') * sym * lit('>')
local column =
    lpeg.Ct(lpeg.Cg(lpeg.C(coltype), 'type') *
    fkey^-1 *
    lit(' ') *
    lpeg.Cg(sym, 'name') *
    lit('?')^-1 *
    (lit(' // ') * (1 - lpeg.S('\n'))^0)^-1 *
    lit('\n'))
local columns = lit('COLUMNS\n') * lpeg.Ct(column^0)
local dbd = lpeg.Ct(lpeg.Cg(columns, 'columns') * -lpeg.P(1))

local parse = function(s)
  return dbd:match(s)
end

return {
  parse = parse,
}
