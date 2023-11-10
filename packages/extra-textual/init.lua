local base = require "packages.base"

local package = pl.class(base)
package._name = "extra-textual"

function package:_init()
  base._init(self)
end

function package:registerCommands()
  self:registerCommand("front", function(options, content) -- fronstispiece
    options.id              = options.id or "front"
    options.title           = options.title or SILE.scratch.book.title or " "
    options.author          = options.author or SILE.scratch.book.author or " "
    options.imprint         = options.imprint or SILE.scratch.book.imprint or " "
    options.backgroundColor = options.backgroundColor or SILE.scratch.styles.colors.front or "#00000"
    -- SILE.call("background", {  allpages = false, color = options.backgroundColor })
    SILE.call("switch-master-one-page", { id = options.id })


    options.linedistance = options.linedistance or SILE.scratch.styles.linedistance or "15pt"

    local fontfamily     = function(field)
      return options.fontfamily or SILE.scratch.styles.fonts[field][1] or "Cormorant"
    end

    local fontsize       = function(field)
      return options.fontsize or SILE.scratch.styles.fonts[field][2] or "16pt"
    end

    local fontweight     = function(field)
      return options.fontsize or SILE.scratch.styles.fonts[field][3] or "400"
    end

    local justification  = function(field)
      return options.justification or SILE.scratch.styles.alingments[field] or "center"
    end

    local frames         = { "author", "title", "subtitle", "imprint", "isbn" } -- possible frames for cover; to be improved

    SILE.call("nofolios")

    if content then
      SILE.process(content)
    end

    for _, frame in ipairs(frames) do
      if SILE.scratch.styles.frames.front.frameset[frame] then
        SILE.call("align", { item = justification(frame) }, function()
          SILE.call("front-item",
            { id = frame, family = fontfamily(frame), size = fontsize(frame), weight = fontweight(frame) },
            function()
              SILE.typesetter:typeset(options[frame])
            end)
        end)
      end
    end

    SILE.call("supereject")
  end, "")
end

package.documentation = [[
\begin{document}

\chapter{Extra-textual}

What the \autodoc:package{extra-textual} package does is \dash as its name suggests \dash create the parts of a book that are not part of the textual body, like the cover, printing and edition notice, ...


\end{document}
]]

return package
