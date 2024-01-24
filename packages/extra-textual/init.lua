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
            SILE.process(content)
        end)
      end)
    end
  end

  self:registerCommand("front", function(options, content) -- fronstispiece
    if front then
      SILE.call("pagetemplate", { ["first-content-frame"] = "title" }, function ()
        for name, frame in pairs(front) do
          SILE.call("frame", {
            id = name,
            x = frame.x,
            y = frame.y,
            width = frame.width,
            height = frame.height,
            top = frame.top,
            bottom = frame.bottom,
            left = frame.left,
            right = frame.right
          })
        end
      end)

      SILE.process(content)

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
