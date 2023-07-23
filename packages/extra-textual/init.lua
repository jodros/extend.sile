local base = require "packages.base"
local super = require "aux.super"
local inspect = require "inspect"


local package = pl.class(base)
package._name = "extra-textual"



function package:_init()
	base._init(self)
end

function package:registerCommands()
	self:registerCommand("edition-notice",
		function() -- verso do olho, ficha catalográfica, créditos institucionais, equipe... Pode ser usado tanto na parte pré quanto na pós textual

		end, "")


	self:registerCommand("front-item", function(options, content)
		--  id for frame MUST be in the frameset pointed in \cover
		SILE.call("typeset-into", { frame = options.id }, function()
			SILE.call("font:" .. options.id, { family = options.family, size = options.size, weight = options.weight },
				content)
		end)
	end)

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




	self:registerCommand("printing-notice", function() -- table of contents
		-- local msg = self.class.packages.styles.readyMade.printingNotice

		local notice = "O corpo deste livro foi composto em ..."



		SILE.call("nofolios")
		--SILE.call("switch-master-one-page", { id =  })
	end, "")



	self:registerCommand("index", function(options)
		for index, value in pairs(SILE.scratch.index) do
			SILE.call("font:main", {}, function()
				SILE.typesetter:typeset(value)
			end)
			SILE.call("par")
		end
	end)

	-- end)








	self:registerCommand("serial", function(options)
		-- options.kind = options.kind or "black"
		-- options.justification = options.justification or "center"

		options.times = options.times or 950

		options.font = options.font or SILE.scratch.styles.fonts.special[1]
		options.size = options.size or SILE.scratch.styles.fonts.serial[2] .. "%ph"
		options.weight = options.weight or SILE.scratch.styles.fonts.special[3]
		-- options.symbol = options.symbol or SILE.scratch.styles.symbols.ellipsis


		options.colors = options.colors or
			{ main = SILE.scratch.styles.colors.main, secondary = SILE.scratch.styles.colors.secondary }


		if options.symbol == "triangular" then
			SILE.call("nospace", { words = "0pt" })
		else
			SILE.call("nospace")
		end

		SILE.call("background", { allpages = "false", color = tostring(options.colors.secondary) })

		local line, max = SILE.scratch.styles.garnish[options.symbol], (100 / SILE.scratch.styles.fonts.serial[2])

		for i = 1, options.times do -- 949
			line = line .. "\n" .. SILE.scratch.styles.garnish[options.symbol]
		end


		SILE.call("neverindent")


		-- SILE.call("skip", { height = "4%ph" })
		-- SILE.call(options.justification, {}, function()
		if options.rotate == "true" then
			SILE.call("switch-master-one-page", { id = "maxrotated" })
		else
			SILE.call("switch-master-one-page", { id = "max" })
		end




		SILE.call("color", { color = tostring(options.colors.main) }, function()
			SILE.call("font", { family = options.font, size = options.size }, function()
				SILE.typesetter:typeset(line)
			end)
		end)





		-- end)
		-- SILE.call("skip", { height = "4%ph" })
		SILE.call("pagebreak")
		-- SILE.call("simple")
	end, "")
end

package.documentation = [[
\begin{document}

\chapter{Extra-textual}

What the \autodoc:package{extra-textual} package does is \dash as its name suggests \dash create the parts of a book that are not part of the textual body, like the cover, printing and edition notice, ...


\end{document}
]]

return package
