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
    self:registerCommand("ellipsis", function(options)
        options.size = options.size or SILE.scratch.styles.ellipsis.size or SILE.scratch.styles.fonts.special[2]
        options.weight = options.weight or SILE.scratch.styles.ellipsis.weight or SILE.scratch.styles.fonts.special[3]
        options.symbol = options.symbol or SILE.scratch.styles.ellipsis.symbol
        options.rotate = options.rotate or SILE.scratch.styles.ellipsis.rotate
        options.font = options.font or function()
            if options.symbol == "⁂" then
                return "Cormorant Garamond"
            else
                return SILE.scratch.styles.ellipsis.font or SILE.scratch.styles.fonts.special[1]
            end
        end

        SILE.call("skip", {
            height = "4%ph"
        })
        SILE.call("align", {
            item = "center"
        }, function()
            SILE.call("font", {
                family = options.font(),
                size = options.size,
                weight = options.weight
            }, function()
                if options.rotate then
                    SILE.call("rotate", {
                        angle = "45"
                    }, function()
                        SILE.typesetter:typeset(SILE.scratch.styles.ellipsis.symbol)
                    end)
                else
                    SILE.typesetter:typeset(SILE.scratch.styles.ellipsis.symbol)
                end
            end)
        end)
        SILE.call("skip", {
            height = "4%ph"
        })
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
        local align = options.align or SILE.scratch.styles.alingments.epigraph or "right"
        SILE.call("align", {
            item = align
        }, function()
            SILE.call("font", {}, content)
        end)
    end)

    self:registerCommand("epigraph", function(options, content)
        local align = options.align or SILE.scratch.styles.alingments.epigraph or "right"
        local width = options.width or "50%fw"
        local skip = SILE.getFrame("content"):width() - SILE.length(width):absolute()

        SILE.settings:temporarily(function()
            SILE.typesetter:leaveHmode()

            if align == "right" then
                SILE.settings:set("document.lskip", SILE.nodefactory.glue(skip))
            elseif align == "left" then
                SILE.settings:set("document.rskip", SILE.nodefactory.glue(skip))
            end

            SILE.call("font:epigraph", {}, content)

            SILE.call("bigskip")
            -- SILE.typesetter:leaveHmode()
        end)
    end)

    self:registerCommand("chapter", function(options, content)
        options.noskip = options.noskip or SILE.scratch.config.noskip
        options.nopagebreak = options.nopagebreak or SILE.scratch.config.chapter.nopagebreak

        local lang = SILE.settings:get("document.language")

        SILE.typesetter:leaveHmode()

        SILE.call("tocentry", {}, content)
        SILE.call("increment-counter", {
            id = "chapters"
        })

        -- the chapter index number should be checked before!!!
        if SILE.scratch.counters.chapters.value == 1 then
            SILE.call("set-counter", {
                id = "footnote",
                value = 1
            })
        end

        -- options.nopagebreak = true
        if options.nopagebreak then
            SILE.call("bigskip")
        elseif not options.noeject then
            SILE.call("forprint")
        end

        -- SILE.call("skip", { height = "10%ph" })
        if options.case == "capital" then
            SILE.call("uppercase", {}, content)
        elseif options.case == "lower" then
            SILE.call("lowercase", {}, content)
        end

        SILE.call("align", {
            item = "chapter"
        }, function()
            SILE.call("font:chapters", {}, content)
        end)

        if not options.noskip then
            SILE.call("skip", {
                height = "7%ph"
            })
        else
            SILE.call("bigskip")
        end

        -- SILE.call("left-running-head", {}, function()
        -- 	SILE.settings:temporarily(function()
        -- 		SILE.call("book:left-running-head-font", {}, content)
        -- 	end)
        -- end)

        SILE.call("bigskip")
        SILE.call("nofoliothispage")

        if lang == 'en' then -- English typography (notably) expects the first paragraph under a section not to be indented
            SILE.call("noindent")
        end
    end)

    self:registerCommand("versalete", function (options, content)
        SILE.call("font:versalete", options , function ()
           SILE.call("lowercase", {}, content) 
        end)
    end)

    self:registerCommand("pause", function (options, content)
        SILE.call("skip", { height = "4%ph" })
        SILE.call("center", {}, function ()
            SILE.call("versalete",{ size = "2em" }, content)
        end)
        SILE.call("skip", { height = "4%ph" })
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

    self:registerCommand("toolsinfo", function ()
        -- local 
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
