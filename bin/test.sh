#!/bin/bash
set -e
eval $(.lua/bin/luarocks path)
.lua/bin/luacheck -q .
.lua/bin/luarocks build --no-install
.lua/bin/luarocks test -- "$@"
