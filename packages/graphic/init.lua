local base = require "packages.base"

local package = pl.class(base)
package._name = "graphic"

function package:_init()
    base._init(self)
end

function package:registerCommands()
    self:registerCommand("pic", function (options, content)
        local align = options.align or "center"
        local width = options.width or SILE.scratch.config.pic.width
        local height = options.height or SILE.scratch.config.pic.height
        local skip = options.skip or SILE.scratch.config.pic.skip

        if SU.boolean(options.full) then
          SILE.call("typeset-into", { frame = "page" }, function()
              SILE.call("noindent")
              SILE.call("img", { src = options.src, height = "100%ph" })
          end) 
        else
         SILE.settings:temporarily(function ()
            SILE.settings:set("document.parskip", "1pt")

            SILE.call("double-skip", { height = skip }, function()
              SILE.call("align", { item = align }, function ()
                  SILE.call("img", { src = options.src, width = width, height = height })
                  SILE.call("par")
                  SILE.call("font:caption", {}, content)
                  SILE.call("par")
              end)  
            end)
         end)
       end
   end)
end

return package

