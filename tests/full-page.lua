return function ()
  local plain = require "classes.extend.plain"
  local class = plain()
  SILE.documentState.documentClass = class

  SILE.call("typeset-into", { frame = "page" }, function (_, _)
    SILE.call("img", { src = "resources/parana-river.jpg" })
  end)

  SILE.call("supereject")
end
