local base = require("packages.base")
local insp = require "inspect"

local package = pl.class(base)
package._name = "textual"


function package:_init()
	base._init(self)

	if not SILE.scratch.headers then SILE.scratch.headers = {} end
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
		options.size   = options.size or SILE.scratch.styles.ellipsis.size or SILE.scratch.styles.fonts.special[2]
		options.weight = options.weight or SILE.scratch.styles.ellipsis.weight or SILE.scratch.styles.fonts.special[3]
		options.symbol = options.symbol or SILE.scratch.styles.ellipsis.symbol
		options.rotate = options.rotate or SILE.scratch.styles.ellipsis.rotate
		options.font   = options.font or function()
			if options.symbol == "triangular" then
				return "Cormorant Garamond"
			else
				return SILE.scratch.styles.ellipsis.font or SILE.scratch.styles.fonts.special[1]
			end
		end


		SILE.call("skip", { height = "4%ph" })
		SILE.call("align", { item = "center" }, function()
			SILE.call("font", { family = options.font(), size = options.size, weight = options.weight }, function()
				if options.rotate then
					SILE.call("rotate", { angle = "45" }, function()
						SILE.typesetter:typeset(SILE.scratch.styles.garnish[options.symbol])
					end)
				else
					SILE.typesetter:typeset(SILE.scratch.styles.garnish[options.symbol])
				end
			end)
		end)
		SILE.call("skip", { height = "4%ph" })
	end, "")




	self:registerCommand("dash", function()
		SILE.call("font", { style = "normal" }, function()
			SILE.typesetter:typeset("―")
		end)
	end, "")


	self:registerCommand("highlight", function(options, content)
		options.space = options.space or "3.5%fh"

		SILE.call("skip", { height = options.space })

		SILE.call("font:main", {}, function()
			SILE.call("center", {}, function()
				SILE.call("em", {}, content)
			end)
		end)

		SILE.call("skip", { height = options.space })
	end)






	self:registerCommand("chapter", function(options, content)
		local lang = SILE.settings:get("document.language")

		SILE.typesetter:leaveHmode()

		SILE.call("tocentry", {}, content)
		SILE.call("increment-counter", { id = "chapters" })

		-- the chapter index number should be checked before!!!
		if SILE.scratch.counters.chapters.value == 1 then
			SILE.call("set-counter", { id = "footnote", value = 1 })
		end

		if not options.noeject then
			SILE.call("forprint")
		end

		-- SILE.call("skip", { height = "10%ph" })
		if options.case == "capital" then
			content[1] = string.upper(content[1][1])
		elseif options.case == "lower" then
			content[1] = string.lower(content[1][1])
		end

		SILE.call("align", { item = "chapter" }, function()
			SILE.call("font:chapters", {}, content)
		end)

		SILE.call("skip", { height = "7%ph" })


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


	self:registerCommand("epigraph", function(options, content)
		options.align = SILE.scratch.styles.alingments.epigraph or "left"

		SILE.settings:temporarily(function()
			local parindent =
					options.parindent ~= nil and SU.cast("glue", options.parindent)
					or SILE.settings:get("document.parindent")
			local width =
					options.width ~= nil and SU.cast("measurement", options.width)
					or SILE.settings:get("epigraph.width")
			local margin =
					options.margin ~= nil and SU.cast("measurement", options.margin)
					or SILE.settings:get("epigraph.margin")

			SILE.settings:set("document.parindent", parindent)

			SILE.call("neverindent")

			options.lines = options.lines or "10%lh" -- line height

			SILE.settings:set("linespacing.method", "fixed")
			SILE.settings:set("linespacing.fixed.baselinedistance", SILE.length(options.lines))

			SILE.call("noindent")

			SILE.call("skip", { height = "4%ph" })

			local frame = SILE.getFrame("content")
			local left, right = frame:left(), frame:right()

			SILE.call("breakframevertical")

			local framew = SILE.typesetter.frame:width()
			local epigraphw = width:absolute()
			local skip = framew - epigraphw - margin
			SILE.typesetter:leaveHmode()

			if SILE.scratch.styles.alingments.epigraph == "right" then
				SILE.settings:set("document.lskip", SILE.nodefactory.glue(skip))
				SILE.settings:set("document.rskip", SILE.nodefactory.glue(margin))
				-- SILE.call("shiftframeedge", { left = "20%fw" })
			elseif SILE.scratch.styles.alingments.epigraph == "left" then
				SILE.settings:set("document.lskip", SILE.nodefactory.glue(margin))
				SILE.settings:set("document.rskip", SILE.nodefactory.glue(skip))
				-- SILE.call("shiftframeedge", { right = "-20%fw" })
			else
				-- undocumented because ugly typographically, IMHO
				SILE.settings:set("document.lskip", SILE.nodefactory.glue((skip + margin) / 2))
				SILE.settings:set("document.lskip", SILE.nodefactory.glue((skip + margin) / 2))
			end



			SILE.call("font",
				{ family = SILE.scratch.styles.fonts.epigraph[1], size = SILE.scratch.styles.fonts.epigraph[2] },
				function()
					SILE.call("em", {}, content)
				end)

			if options.reference then
				SILE.call("footnote", {}, function ()
					SILE.typesetter:typeset(options.reference)
				end)
			end

			SILE.call("par")

			SILE.call("align", { item = SILE.scratch.styles.alingments.epigraph }, function()
				SILE.call("font", {},
					function()
						if options.work then
							SILE.typesetter:typeset(options.work .. ", ")
						end

						if options.author then
							if options.dash == "true" then
								SILE.call("dash")
								SILE.typesetter:typeset(" ")
							end

							SILE.typesetter:typeset(options.author)
						end
					end)
			end)



			SILE.typesetter:leaveHmode()
			SILE.call("skip", { height = "5%ph" })

			SILE.call("indent")
		end)
		-- SILE.call("breakframevertical")

		-- if SILE.scratch.styles.alingments.epigraph == "right" then
		-- 	SILE.call("shiftframeedge", { left = "-20%fw" })
		-- elseif SILE.scratch.styles.alingments.epigraph == "left" then
		-- 	SILE.call("shiftframeedge", { right = "20%fw	" })
		-- end
	end, "")



	self:registerCommand("internal-quote", function(options, content)
		SILE.call("hfill")
		SILE.call("breakframevertical")
		SILE.call("shiftframeedge", { left = "10%pw", right = "-10%pw" })

		SILE.call("par")
		--ySILE.call("showframe", { id = "all" })

		SILE.call("center", {}, function()
			SILE.call("noindent")

			SILE.call("skip", { height = "4%ph" })
			--		SILE.call("font", { family = "gabriela", size = "11pt" }, function () 	
			SILE.call("em", {}, content)
			--		end)

			SILE.call("par")
		end)

		SILE.call("breakframevertical")
	end)
end

package.documentation = [[
\begin{document}



offers a bunch of dingbats and pontuaction marks like \code{\dash} \autodoco:command{\dash}


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
