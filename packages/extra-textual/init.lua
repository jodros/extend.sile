local base = require "packages.base"
local inspect = require "inspect"

local package = pl.class(base)
package._name = "extra-textual"

function package:_init()
  base._init(self)
end

function package:registerCommands()
  self:registerCommand("front", function(options, content) -- fronstispiece
  end)
end

package.documentation = [[
\begin{document}

\chapter{Extra-textual}

What the \autodoc:package{extra-textual} package does is \dash as its name suggests \dash create the parts of a book that are not part of the textual body, like the cover, and edition notice, ...

\end{document}
]]

return package
