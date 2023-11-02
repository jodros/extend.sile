return function()
    local plain = require "classes.hooking"
    local class = plain()
    SILE.documentState.documentClass = class
    
    -- SILE.call("font:headers")
    SILE.call("ellipsis")
end