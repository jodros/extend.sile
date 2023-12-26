return function()
    local plain = require "classes.plain"
    local class = plain()
    SILE.documentState.documentClass = class

    local x, y = "40%pw", "60%ph"
    local w, h = "50%pw", "25%ph"

    class:defineMaster({
        id = "center",
        firstContentFrame = "content",
        frames = {
            content = {
                left = x..'-(' .. w .. "/2)",
                right = x .. "+(" .. w .. "/2)",
                top = y..'-(' .. h .. "/2)",
                bottom = y.."+" .. "+(" .. h .. "/2)"
            }      
        }
    })

    SILE.call("switch-master", {id="center"}) 

    SILE.call("lorem", {words=10})

end
