local base = require("packages.base")

local package = pl.class(base)
package._name = "abnt"

function package:_init()
	base._init(self)

end

function package:registerCommands()

	self:registerCommand("", function(options, content)
	end)
end

package.documentation = [[
\begin{document}

The \autodoc:package{abnt} aims to automatically render your text according to the rules of ABNT...

\end{document}
]]

return package
