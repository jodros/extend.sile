local base = require "packages.base"
local inspect = require "inspect"

local package = pl.class(base)
package._name = "extra-textual"

function package:_init()
  base._init(self)
end

function package:registerCommands()
  local front = SILE.scratch.config.frames.front

  if front then
    for name in pairs(front) do
      self:registerCommand(name, function (options, content)
        SILE.call("typeset-into", { frame = name }, function ()
            SILE.call("align", { item = name }, function ()
              SILE.call("font:"..name, {}, function ()
                if content[1] then
                  SILE.process(content) 
                elseif not content[1] and SILE.scratch.config.book[name] then
                  SILE.typesetter:typeset(SILE.scratch.config.book[name])
                else
                  SU.error("STUPID ERROR") -- I know this line should be different but I'm lazy
                end
              end)
            end)
          end)
        end)
     end
  end

  self:registerCommand("front", function(options, content) -- fronstispiece
    if options.backcolor then SILE.call("background", {allpages=false, color=options.backcolor}) end
    
    if front then
      SILE.call("pagetemplate", { ["first-content-frame"] = "author" }, function ()
        for name, frame in pairs(front) do
          SILE.call("frame", {
            id = name,
            x = frame.x or SILE.scratch.styles.alingments.front.x,
            y = frame.y,
            width = frame.width,
            height = frame.height,
            top = frame.top,
            bottom = frame.bottom,
            left = frame.left or SILE.scratch.styles.alingments.front.left,
            right = frame.right or SILE.scratch.styles.alingments.front.right
          })
        end
      end)

      SILE.process(content)

      SILE.call("pagebreak")
      SILE.call("pagebreak")
    else
      SU.error("No 'front' frameset declared!")
    end
  end)
end

package.documentation = [[
\begin{document}

\chapter{Extra-textual}

What the \autodoc:package{extra-textual} package does is \dash as its name suggests \dash create the parts of a book that are not part of the textual body, like the cover, and edition notice, ...

\end{document}
]]

return package
