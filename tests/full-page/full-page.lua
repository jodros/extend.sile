return function()
  --  local plain = require "classes.extend.plain"
  local plain = require "classes.plain"
  local class = plain({landscape=true})
  SILE.documentState.documentClass = class

  SILE.call("neverindent")

  SILE.call("typeset-into", { frame = "page" }, function (_, _)
    SILE.call("img", { width = SILE.documentState.paperSize[1], height = SILE.documentState.paperSize[2], src = "resources/parana-river.jpg" })
  end)
end
