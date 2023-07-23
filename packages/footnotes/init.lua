local base = require("packages.base")

local package = pl.class(base)
package._name = "footnotes"

function package:_init (options)
  base._init(self)
  self:loadPackage("counters")
  self:loadPackage("raiselower")
  self:loadPackage("insertions")
  self:loadPackage("rules")
  if not SILE.scratch.counters.footnotes then
    SILE.scratch.counters.footnote = { value = 1, display = "arabic" }
  end
  options = options or {}
  self.class:initInsertionClass("footnote", {
    insertInto = options.insertInto or "footnotes",
    stealFrom = options.stealFrom or { "content" },
    maxHeight = SILE.length("75%ph"),
    topBox =  SILE.nodefactory.vglue("2ex"),
    interInsertionSkip = SILE.length("1ex"),
  })
end

function package:registerCommands ()

  self:registerCommand("footnotemark", function (_, _)
    SILE.call("raise", { height = "0.7ex" }, function ()
      SILE.call("font", { size = "1.5ex" }, function ()
        SILE.typesetter:typeset(self.class.packages.counters:formatCounter(SILE.scratch.counters.footnote))
      end)
    end)
  end)

  self:registerCommand("footnote:separator", function (_, content)
    SILE.settings:pushState()
    local material = SILE.call("vbox", {}, content)
    SILE.scratch.insertions.classes.footnote.topBox = material
    SILE.settings:popState()
  end)

  self:registerCommand("footnote:options", function (options, _)
    if options["maxHeight"] then
      SILE.scratch.insertions.classes.footnote.maxHeight = SILE.length(options["maxHeight"])
    end
    if options["interInsertionSkip"] then
      SILE.scratch.insertions.classes.footnote.interInsertionSkip = SILE.length(options["interInsertionSkip"])
    end
  end)

  self:registerCommand("footnote", function (options, content)
    if SILE.scratch.test.show  then
			SILE.call("showframe", { id = "all" })
		end
    SILE.call("footnotemark")
    local opts = SILE.scratch.insertions.classes.footnote or {}
    local frame = opts.insertInto and SILE.getFrame(opts.insertInto.frame)
    local oldGetTargetLength = SILE.typesetter.getTargetLength
    local oldFrame = SILE.typesetter.frame
    SILE.typesetter.getTargetLength = function () return SILE.length(0xFFFFFF) end
    SILE.settings:pushState()
    -- Restore the settings to the top of the queue, which should be the document #986
    SILE.settings:toplevelState()
    SILE.typesetter:initFrame(frame)

    -- Reset settings the document may have but should not be applied to footnotes
    -- See also same resets in folio package
    for _, v in ipairs({
      "current.hangAfter",
      "current.hangIndent",
      "linebreak.hangAfter",
      "linebreak.hangIndent" }) do
      SILE.settings:set(v, SILE.settings.defaults[v])
    end

    -- Apply the font before boxing, so relative baselineskip applies #1027
    local material
    SILE.call("font:footnotes", {}, function ()
        material = SILE.call("vbox", {}, function ()
        SILE.call("footnote:atstart", options)
        SILE.call("footnote:counter", options)
        SILE.process(content)
      end)
    end)
    SILE.settings:popState()
    SILE.typesetter.getTargetLength = oldGetTargetLength
    SILE.typesetter.frame = oldFrame
    self.class:insert("footnote", material)
    SILE.scratch.counters.footnote.value = SILE.scratch.counters.footnote.value + 1
  end)

  -- self:registerCommand("footnote:font", function (_, content)
  --   -- The footnote frame has is settings reset to the toplevel state, so if one does
  --   -- something relative (as below), it is expected to be the main value from the
  --   -- document.
  --   SILE.call("font", { size = SILE.settings:get("font.size") * 0.9 }, function ()
  --     SILE.process(content)
  --   end)
  -- end)

  self:registerCommand("footnote:atstart", function (_, _)
  end)

  self:registerCommand("footnote:counter", function (_, _)
    SILE.call("noindent")
    SILE.typesetter:typeset(self.class.packages.counters:formatCounter(SILE.scratch.counters.footnote) .. ".")
    SILE.call("qquad")
  end)

end

package.documentation = [[
\begin{document}
We’ve seen that the \code{book} class allows you to add footnotes to text with the \autodoc:command{\footnote} command.
This functionality exists in the class because the class loads the \autodoc:package{footnotes} package.
The \code{book} class loads the \autodoc:package{insertions} package and tells it which frame should receive the footnotes that are typeset.
Other commands provided by the \autodoc:package{footnotes} package take care of formatting the footnotes.
\end{document}
]]

return package
