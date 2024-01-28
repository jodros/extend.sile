local base    = require("packages.base")
-- local color   = require("lua-color")
local inspect = require("inspect")

local package = pl.class(base)
package._name = "styles"


function package:_init(options)
	base._init(self)
	options = options or {}

	-- if SILE.scratch.styles.spacing.words then
	-- 	SILE.settings:set("shaper.variablespaces", false)
	-- 	SILE.settings:set("document.spaceskip", SILE.length(SILE.scratch.styles.spacing.words))
	-- end

	-- if SILE.scratch.styles.spacing.lines then
	-- 	SILE.settings:set("linespacing.fixed.baselinedistance", SILE.length(SILE.scratch.styles.spacing.lines))
	-- end

	-- if SILE.scratch.styles.spacing.letters then
	-- 	SILE.settings:set("document.letterspaceglue", SILE.length(SILE.scratch.styles.spacing.letters))
	-- end

	-- if SILE.scratch.styles.spacing.paragraphs then
	-- 	SILE.settings:set("document.parskip", SILE.length(SILE.scratch.styles.spacing.paragraphs))
	-- end
end

local direction = function(option, content)
	if SILE.scratch.styles.alingments[option] == "left" or option == "left" then
		return SILE.call("ragged", { right = true }, content)
	elseif SILE.scratch.styles.alingments[option] == "right" or option == "right" then
		return SILE.call("ragged", { left = true }, content)
	elseif SILE.scratch.styles.alingments[option] == "center" or option == "center" then
		return SILE.call("center", {}, content)
	else
		return SILE.process(content)
	end
end

function package:registerCommands()
	self:registerCommand("forprint", function(_, _) -- disables/enables features according to pdf purpose
		if SILE.scratch.styles.forprint then -- It doesn't need blank pages if it going to be only digital..
			SILE.call("open-spread")
		else
			SILE.call("supereject")
		end
	end)

	-- SPACING

	self:registerCommand("nospace", function(options) -- used for garnish like in serial...
		options.words      = options.words or "-1%pw"
		options.lines      = options.lines or "2.7%ph"
		options.letters    = options.letters or "0"
		options.paragraphs = options.paragraphs or "5pt"


		SILE.settings:set("shaper.variablespaces", false)
		SILE.settings:set("document.spaceskip", SILE.length(options.words))
		SILE.settings:set("document.parskip", SILE.length(options.paragraphs))
		SILE.settings:set("document.letterspaceglue", SILE.length(options.letters))
		SILE.settings:set("linespacing.method", "fixed")
		SILE.settings:set("linespacing.fixed.baselinedistance", SILE.length(options.lines))
	end, "")


	self:registerCommand("resetspace", function(_, _)
		SILE.settings:set("shaper.variablespaces", true)
		SILE.settings:set("document.spaceskip")
		SILE.settings:set("linespacing.fixed.baselinedistance")
		SILE.settings:set("document.letterspaceglue")
		SILE.settings:set("document.parskip")
	end, "")

	-- END SPACING

	-- ALIGNMENTS

	self:registerCommand("align", function(options, content)
		direction(options.item, content)
	end, "")

	self:registerCommand("vertical-align", function(options, content)
		if options.item == "center" then
			SILE.call("hbox")
			SILE.call("vfill")
			SILE.typesseter:typesset(content)
			SILE.call("eject")
		end
	end, "")

	-- END ALIGNMENTS

	-- FONTS

	for item in pairs(SILE.scratch.styles.fonts) do
		self:registerCommand("font:" .. item, function(options, content)
			options.color = options.color or SILE.scratch.styles.fonts[item][6] or "#000000" -- default is black

			SILE.call("color", { color = options.color }, function()
				SILE.call("font", {
					family = SILE.scratch.styles.fonts[item][1],
					size   = SILE.scratch.styles.fonts[item][2],
					weight = SILE.scratch.styles.fonts[item][3],
					variant = SILE.scratch.styles.fonts[item][4],
					style = SILE.scratch.styles.fonts[item][5]
				}, content)
			end)
		end)
	end

	-- END FONTS
end

package.documentation = [[
\begin{document}
\chapter{Styles}

The \autodoc:package{styles} package was created for the sake of simplicity when editing a book, it allows to change (almost) any styling option for the entire document only from a \verbatim{settings.toml} file in your working directory. Firstly, it comes together with a \verbatim{default.toml} file, containing all the options, every time you run sile with the \verbatim{flex} class, it is going to look at this file as the main reference in order to set which framesets are going to serve as master, the family name of the fonts, its sizes and weights, the alingments for each item like chapters, epigraphs, cover, and so on.


\autodoc:command{\font:chapters} (or \verbatim{:main, :title...} etc... ): get all parameters like \em{ family, size, weight } from the \verbatim{default.toml} and \verbatim{settings.toml} files and automatically applies to the document.

\chapter{default.toml}
\verbatim{
-- ]] .. "super(SILE.scratch.paths.default, 'string')" .. [[}
\bigskip

So let us say you want to set the




\end{document}
]]



return package
