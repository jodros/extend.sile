return function()
  --  local plain = require "classes.extend.plain"
  local plain = require "classes.plain"
  local class = plain()
  SILE.documentState.documentClass = class
  local insp = require "inspect"

  for key, value in pairs(class.packages) do
    print(key)
  end

  --  SILE.call("typeset-into", { frame = "page" }, function (_, _)
  --    SILE.call("img", { src = "resources/parana-river.jpg" })
  --  end)
  --
  --  SILE.call("supereject")
end
