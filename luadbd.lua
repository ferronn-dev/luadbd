local lpeg = require('lpeg')

local lit = lpeg.P
local sp = lpeg.S(' \n')^0
local coltype = lit('int') + lit('string') + lit('float') + lit('locstring')
local sym = lpeg.R('az', 'AZ') * lpeg.R('az', 'AZ', '09')^0
local fkey = lit('<') * sym * lit('::') * sym * lit('>')
local column = lpeg.Ct(lpeg.Cg(lpeg.C(coltype), 'type') * fkey^-1 * sp * lpeg.Cg(sym, 'name') * lit('?')^-1 * sp)
local columns = lit('COLUMNS') * sp * lpeg.Ct(column^0)
local dbd = lpeg.Ct(sp * lpeg.Cg(columns, 'columns') * -lpeg.P(1))

local parse = function(s)
  return dbd:match(s)
end

return {
  parse = parse,
}
