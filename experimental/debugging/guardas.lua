return function()
  local flex = require("classes.flex")
  local class = flex({ papersize = "a6" }) -- SILE.scratch.styles.papersize

  SILE.call("simple")
  SILE.documentState.documentClass = class
  SILE.call("font", { family = SILE.scratch.styles.fonts.main, size = SILE.scratch.styles.fonts.size.main })

  local Color = require "lua-color"

  local color = Color(SILE.scratch.styles.colors.main)
  local _color = Color(SILE.scratch.styles.colors.secondary)


  local compoundA, _, compoundB = color:compound()
  local _, triadA, triadB = color:triad()
  local _, analogousA, analogousB = color:analogous()

  local _compoundA, _, _compoundB = _color:compound()
  local _, _triadA, _triadB = _color:triad()
  local _, _analogousA, _analogousB = _color:analogous()

  local colorlist = {
    main = {
      "#000000",
      "#ffffff",

      color,
      -- color:grey(),
      -- color:invert(),
      -- color:rotate(0.5),
      -- color:rotate { deg = 180 },
      -- color:rotate { rad = math.pi },
      color:complement(),
      compoundA,
      compoundB,
      triadA,
      triadB,
      analogousA,
      analogousB,
    },

    secondary = {
      "#ffffff",
      "#000000",
      _color,
      -- _color:grey(),
      -- _color:invert(),
      -- _color:rotate(0.5),
      -- _color:rotate { deg = 180 },
      -- _color:rotate { rad = math.pi },
      _color:complement(),
      _compoundA,
      _compoundB,
      _triadA,
      _triadB,
      _analogousA,
      _analogousB,
    }
  }


  for i = 1, #colorlist.main do
    SILE.call("serial",
      { rotate = "true", symbol = "loopedSquare", times = 4600,
        colors = { main = colorlist.main[i], secondary = colorlist.secondary[i] } })
    SILE.call("supereject")
  end
end
