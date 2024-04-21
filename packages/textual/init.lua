local base = require("packages.base")
local insp = require "inspect"

local package = pl.class(base)
package._name = "textual"

function package:_init()
    base._init(self)
end

function package.declareSettings(_)
    SILE.settings:declare({
        parameter = "epigraph.width",
        type = "measurement",
        default = SILE.measurement("65%lw"),
        help = "Width of an epigraph (defaults to 60% of the current line width)."
    })

    SILE.settings:declare({
        parameter = "epigraph.margin",
        type = "measurement",
        default = SILE.measurement(),
        help = "Margin (indent) for an epigraph (defaults to 0)."
    })
end

function package:registerCommands()
    self:registerCommand("double-skip", function(options, content)
        SILE.call("skip", { height = options.height })
        SILE.process(content)
        SILE.call("skip", { height = options.height })
    end)

    self:registerCommand("ellipsis", function(options, content)
        local size = options.size or SILE.scratch.styles.ellipsis.size or SILE.scratch.styles.fonts.special[2]
        local weight = options.weight or SILE.scratch.styles.ellipsis.weight or SILE.scratch.styles.fonts.special[3]
        local symbol = options.symbol or SILE.scratch.styles.ellipsis.symbol
        local rotate = options.rotate or SILE.scratch.styles.ellipsis.rotate
        local font = options.font or function()
            if symbol == "⁂" then
                return "Cormorant Garamond"
            else
                return SILE.scratch.styles.ellipsis.font or SILE.scratch.styles.fonts.special[1]
            end
        end
        local skip = options.skip or SILE.scratch.config.epigraph.skip
        
        content = content[1] or SILE.scratch.styles.ellipsis.symbol

        SILE.call("double-skip", { height = skip}, function()
          SILE.call("align", { item = "center" }, function()
              SILE.call("font", {
                  family = font(),
                  size = size,
                  weight = weight }, function()
                  if rotate then
                    SILE.call("rotate", { angle = "45" }, function()
                      SILE.typesetter:typeset(content)
                    end)
                  else
                      SILE.typesetter:typeset(content)
                  end
              end)
          end)
        end)
    end, "")

    self:registerCommand("dash", function(options, _)
        SILE.call("font", { style = "normal" }, function()
            if options.en then
                SILE.typesetter:typeset("–")
            else
                SILE.typesetter:typeset("―")
            end
        end)
    end, "")

    self:registerCommand("from", {}, function(options, content)
        local align = options.align or SILE.scratch.styles.alignments.epigraph or "right"
        SILE.call("align", {
            item = align
        }, function()
            SILE.call("font", {}, content)
        end)
    end)

    self:registerCommand("epigraph", function(options, content)
        local align = options.align or SILE.scratch.styles.alignments.epigraph
        local width = options.width or SILE.scratch.config.epigraph.width
        local sideskip = SILE.getFrame("content"):width() - SILE.length(width):absolute()
        local skip = options.skip or SILE.scratch.config.epigraph.skip

        SILE.settings:temporarily(function()
            SILE.typesetter:leaveHmode()

            if align == "right" then
                SILE.settings:set("document.lskip", SILE.nodefactory.glue(sideskip))
            elseif align == "left" then
                SILE.settings:set("document.rskip", SILE.nodefactory.glue(sideskip))
            end

            SILE.call("font:epigraph", {}, content)

          if skip then
            SILE.call("skip", { height = skip })
          end
        end)
    end)

    self:registerCommand("chapter", function(options, content)
        local skip = options.skip or (not samepage and SILE.scratch.config.chapter.skip)
        local pagebreak = options.pagebreak or SILE.scratch.config.chapter.pagebreak
        local case = options.case or SILE.scratch.config.chapter.case or "sil"
        local noindent = options.noindent or SILE.scratch.config.chapter.noindent
        local samepage = SILE.scratch.config.chapter.samepage
        local valign = options.valign or (not samepage and SILE.scratch.config.chapter.valign)
        local halign = options.halign or SILE.scratch.config.alignments.chapter -- SILE.scratch.config.chapter.halign

        -- local lang = SILE.settings:get("document.language")

        if noindent then SILE.call("noindent") end

        SILE.typesetter:leaveHmode()

        SILE.call("tocentry", {}, content)
        SILE.call("increment-counter", { id = "chapters" })

        -- the chapter index number should be checked before!!!
        -- TODO add option to reset note count for each new chapter
        if SILE.scratch.counters.chapters.value == 1 then
            SILE.call("set-counter", {
                id = "footnote",
                value = 1
            })
        end

        if breakbefore then SILE.call("forprint") end

        SILE.call("nofoliothispage")
        
        SILE.call("vertical-align", { item = valign }, function()
          SILE.call("align", { item = halign }, function()
            SILE.call("font:chapters", {}, function()
              SILE.call(case, {}, content)
            end)
          end)
        end)
        
        if not samepage then
          SILE.call("pagebreak")
          SILE.call("forprint")
        end

        SILE.call("nofoliothispage")

        if skip then
            SILE.call("skip", { height = skip })
        end

        -- SILE.call("bigskip")
        -- SILE.call("nofoliothispage")

        if noindent then SILE.call("noindent") end
    end)

    self:registerCommand("shrink", function (options, content) -- Not working for the last paragraph!?
        local width = options.width or SILE.scratch.config.shrink.width or "10%pw" 
        local left = options.left or SILE.scratch.config.shrink.left
        local right = options.right or SILE.scratch.config.shrink.right

        SILE.settings:temporarily(function ()
           SILE.settings:set("document.lskip", left or width)
           SILE.settings:set("document.rskip", right or width)
--           content[1][1] = content[1][1] .. "\n\n" -- otherwise the last paragraph won't be shrinked...
           SILE.process(content)
        end)
    end)

    self:registerCommand("versalete", function (options, content)
        SILE.call("font:versalete", options , function ()
           SILE.call("lowercase", {}, content) 
        end)
    end)

    -- LEGAL STUFF

    self:registerCommand("artigo", function(_, content)
        SILE.typesetter:typeset("Art. ")
        SILE.call("sectioning", {
            numbering = true,
            toc = true,
            level = 1
        }, content)
        SILE.typesetter:typeset("º")

        SILE.call("quad")

        SILE.call("font", {}, content)

        SILE.call("par")
    end)

    self:registerCommand("paragrafo", function(_, content)
        SILE.call("qquad")
        SILE.typesetter:typeset("§ ")
        SILE.call("sectioning", {
            numbering = true,
            toc = true,
            level = 1
        }, content)
        SILE.typesetter:typeset("º")

        SILE.call("quad")

        SILE.call("font", {}, content)

        SILE.call("par")
    end)

    self:registerCommand("inciso", function(_, content)
        SILE.call("qquad")
        SILE.call("sectioning", {
            numbering = true,
            display = "roman",
            toc = true,
            level = 1
        }, content)

        SILE.call("enspace")

        SILE.call("dash")
        SILE.call("quad")

        SILE.call("font", {}, content)

        SILE.call("par")
    end)

    ------------

    self:registerCommand("num", function(options)
        local space = options.space or "1em"

        if not SILE.scratch.counters.item then -- temporary name!
            SILE.call("set-counter", { id = "item", value = 1 })
        end

        -- SILE.typesetter:leaveHmode()
        SILE.call("show-counter",{ id = "item"}) 
        SILE.typesetter:typeset(".")        
        SILE.call("glue", { width = space })

        -- SILE.process(content)
        SILE.call("increment-counter", { id = "item" })
    end)

    self:registerCommand("poetry", function(options, content) -- name to be changed
        if options.columns then
            SILE.call("makecolumns", {
                columns = options.columns
            })
        end
      
        string.gsub(tostring(content[1][1]), "[^+\n]+\n+", function(match)
            SILE.typesetter:typeset(match)
            if match:find("\n\n+") then
                SILE.call("medskip")
            else
                SILE.call("par")
            end
        end)
    end)
end


package.documentation = [[
\begin{document}

offers a bunch of dingbats and pontuaction marks like \code{\dash} \autodoc:command{\dash}

The commands that can be changed through the \code{setings.toml} file are the following

SUPPORTED SYMBOLS:
black        = \font:special{■}
white        = \font:special{□}
double       = \font:special{▣}
gridV        = \font:special{▥}
gridH        = \font:special{▤}
chess        = \font:special{▦}
gridTransLR  = \font:special{▨}
gridTransRL  = \font:special{▧}
crossed      = \font:special{▩}
loopedSquare = \font:special{⌘}
triangular   = ⁂

\verbatim{
[ellipsis]
symbol = # currently only supports the symbols declared in the SILE.scratch.styles.garnish table
rotate = boolean
size =
font =
weight =

\end{document}
]]

return package
