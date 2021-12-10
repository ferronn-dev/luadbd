describe('luadbd dbds', function()
  local success, dbds = pcall(function() return require('luadbd.dbds') end)
  it('loads', function()
    assert(success, dbds)
  end)
  assert(type(dbds) == 'table', tostring(dbds))
  for tn, dbd in pairs(dbds) do
    it('can attempt to retrieve specific build in ' .. tn, function()
      assert.True(pcall(function()
        dbd:build('9.1.0.38312')
      end))
    end)
  end
end)
