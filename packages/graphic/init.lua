local base = require "packages.base"

local package = pl.class(base)
package._name = "graphic"

function package:_init()
    base._init(self)
end

function package:registerCommands()
    self:registerCommand("pic", function (options, content)
        local align = options.align or "center"
        local width = options.width
        function wcheck() if not width then return "27%ph" end end
        local height = options.height or wcheck()

        SILE.settings:temporarily(function ()
            SILE.settings:set("document.parskip", "1pt")

            SILE.call("align", { item = align }, function ()
                SILE.call("img", { src = options.src, width = width, height = height })
                SILE.call("par")
                SILE.call("font:caption", {}, content)
                SILE.call("par")
            end)  
        end)
   end)
end

return package