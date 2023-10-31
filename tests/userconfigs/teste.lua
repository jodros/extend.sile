return function()
    local plain = require "classes.plain"
    local class = plain()
    SILE.documentState.documentClass = class
    
    print(SILE.scratch.styles)
end