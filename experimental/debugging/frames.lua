return function()
  local plain                      = require "classes.plain"
  local masters                    = require "packages.masters"
  -- local tab                        = require "tabular"
  local class                      = plain({papersize="a4"})
  SILE.documentState.documentClass = class

  SILE.call("switch-master", { id = "simple" })

  print(class:currentMaster())

  -- local colorfulframe = function(frame, color)
  --   local item = SILE.getFrame(frame)
  --   local backgroundColor = SILE.color(color)
  --   SILE.outputter:pushColor(backgroundColor)
  --   SILE.outputter:drawRule(item:left(), item:top(), item:width(), item:height())
  --   SILE.outputter:popColor()
  -- end

  -- local colors = {
  --   first  = "red",
  --   second = "green",
  --   third  = "black",
  --   fourth = "yellow"
  -- }

  -- for key, _ in pairs(class.pageTemplate.frames) do
  --   if key ~= "folio" then
  --     colorfulframe(key, colors[key])
  --   end
  -- end
end
