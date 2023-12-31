return function()
    local plain = require "classes.plain"
    local x, y = "3cm", "3cm"
    local w, h = "36%pw", "60%ph"

    plain.defaultFrameset =  SILE.scratch.styles.frames.xy
    --     content = {
    --         x = x,
    --         width = w,
    --         y = y,
    --         height = h
    --     }
    -- }
    -- plain.firstContentFrame = "content"
    local class = plain()
    SILE.documentState.documentClass = class
end
