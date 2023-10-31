local base = require("packages.base")
local insp = require "inspect"

local package = pl.class(base)
package._name = "frontal"

function package:_init()
	base._init(self)
end

function package.declareSettings(_)
end

function package:registerCommands()
end

package.documentation = [[
\begin{document}
\end{document}
]]

return package
