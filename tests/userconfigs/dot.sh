#!/usr/bin/env bash

mkdir -p ~/.sile/layouts
rm ~/.sile/default.toml
rm ~/.sile/layouts/generic.toml
ln ../../config/default.toml ~/.sile/
ln ../../config/layouts/generic.toml ~/.sile/layouts/
ls ~/.sile -al *
