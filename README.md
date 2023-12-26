# extend.sile

A bunch of changes and new packages for the SILE typesetting system I've making for personal use. The name is to be changed to a more creative one, someday...

My goal is to actually make books with this extension. 

Although it's a personal project, PRs are welcome. 

All details are still to be written in the documentation...

## Installing

Just run `luarocks --local install extend.sile`, or clone this repository and then run `luarocks --local make`.

## Requirements

I can't tell whether it works with older versions of SILE...
LuaRocks will automatically install the dependencies if you don't have them yet:

- [lua-toml](https://github.com/jonstoler/lua-toml)
- [LuaFileSystem](https://github.com/lunarmodules/luafilesystem)
- [datafile](https://github.com/hishamhm/datafile) 

<!-- Fonts: -->
<!-- - Symbola  is a good option for characters like ▩▤▧⌘... -->
