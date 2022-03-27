#!/bin/bash
v=${1:1}
key=${2}
spec=luadbd-${v}-0.rockspec
eval "$(.lua/bin/luarocks path)"
.lua/bin/luarocks install dkjson
sed s/scm/"${v}"/g < luadbd-scm-0.rockspec > "${spec}"
.lua/bin/luarocks upload --skip-pack --force --temp-key "${key}" "${spec}"
