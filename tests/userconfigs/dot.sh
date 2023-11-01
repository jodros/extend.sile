#!/usr/bin/env bash

rm -r ~/.sile/
mkdir -p ~/.sile/layouts
# cp ../../config/default.toml ~/.sile/
# cp ../../config/layouts/generic.toml ~/.sile/layouts/
ln default.toml ~/.sile/
ln generic.toml ~/.sile/layouts/
ls ~/.sile -al
cat ~/.sile/default.toml
