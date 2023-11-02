return function()
    local plain = require "classes.plain"
    local class = plain()
    SILE.documentState.documentClass = class
    
    SILE.call("font:headers")
end