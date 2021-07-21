local lpeg = require('lpeg')

local lit = lpeg.P
local sp = lpeg.S(' \n')^0
local coltype = lit('int') + lit('string') + lit('float') + lit('locstring')
local sym = lpeg.R('az', 'AZ') * lpeg.R('az', 'AZ', '09')^0
local fkey = lit('<') * sym * lit('::') * sym * lit('>')
local column = coltype * fkey^-1 * sp * sym * lit('?')^-1 * sp
local dbd = sp * lit('COLUMNS') * sp * column^0 * -lpeg.P(1)

local parse = function(s)
  return dbd:match(s)
end

return {
  parse = parse,
}
