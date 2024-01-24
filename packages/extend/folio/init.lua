local base = require("packages.base")

local package = pl.class(base)
package._name = "folio"

function package.incrementFolio(_)
  SILE.scratch.counters.folio.value = SILE.scratch.counters.folio.value + 1
end

local isFolioFrame, folioFrame = nil, {} 

function package:outputFolio(frame)
  if not frame then frame = "folio" end
  local folio = self.class.packages.counters:formatCounter(SILE.scratch.counters.folio)
  io.stderr:write("[" .. folio .. "] ")
  if SILE.scratch.counters.folio.off then
    if SILE.scratch.counters.folio.off == 2 then
      SILE.scratch.counters.folio.off = false
    end
  else
    isFolioFrame, folioFrame = pcall(SILE.getFrame(frame))
    if (folioFrame) then
      SILE.typesetNaturally(folioFrame, function()
        SILE.settings:pushState()
        -- Restore the settings to the top of the queue, which should be the document #986
        SILE.settings:toplevelState()

        -- Reset settings the document may have but should not be applied to footnotes
        -- See also same resets in footnote package
        for _, v in ipairs({
          "current.hangAfter",
          "current.hangIndent",
          "linebreak.hangAfter",
          "linebreak.hangIndent" }) do
          SILE.settings:set(v, SILE.settings.defaults[v])
        end

        SILE.call("foliostyle", {}, { self.class.packages.counters:formatCounter(SILE.scratch.counters.folio) })
        SILE.typesetter:leaveHmode()
        SILE.settings:popState()
      end)
    end
  end
end

function package:_init(options)
  base._init(self)
  self.class:loadPackage("counters")
  SILE.scratch.counters.folio = { value = 1, display = "arabic" }
  self.class:registerHook("newpage", function() self:incrementFolio() end)
  self.class:registerHook("endpage", function () if isFolioFrame then self:outputFolio(options and options.frame) end end)
  self:export("outputFolio", self.outputFolio)
end

function package:registerCommands()
  self:registerCommand("folios", function(_, _)
    SILE.scratch.counters.folio.off = false
  end)

  self:registerCommand("nofolios", function(_, _)
    SILE.scratch.counters.folio.off = true
  end)

  self:registerCommand("nofoliothispage", function(_, _)
    SILE.scratch.counters.folio.off = 2
  end)

  self:registerCommand("nofoliosthispage", function(_, _)
    SU.deprecated("nofoliosthispage", "nofoliothispage", "0.12.1", "0.14.0")
  end, "Deprecated")

  self:registerCommand("foliostyle", function(options, content)
    SILE.call("font",
      {
        family = SILE.scratch.styles.fonts.folio[1],
        size = SILE.scratch.styles.fonts.folio[2],
        weight = SILE.scratch.styles.fonts.folio[3]
      },
      function()
        local styletype = SILE.scratch.styles.alingments.folio

        if styletype == "mirror" then
          if SILE.scratch.counters.folio.value % 2 == 0 then
            SILE.call("raggedright", {}, content)
          elseif SILE.scratch.counters.folio.value % 2 ~= 0 then
            SILE.call("raggedleft", {}, content)
          end
        elseif styletype == "center" then
          SILE.call("center", {}, content)
        end
      end)
  end)
end

package.documentation = [[
\begin{document}
The \autodoc:package{folio} package (which is automatically loaded by the plain class, and therefore by nearly every SILE class) controls the output of folios—the old-time typesetter word for page numbers.

It provides four commands to users:

\begin{itemize}
\item{\autodoc:command{\nofolios}: turns page numbers off.}
\item{\autodoc:command{\nofoliothispage}: turns page numbers off for one page, then on again afterward.}
\item{\autodoc:command{\folios}: turns page numbers back on.}
\item{\autodoc:command{\foliostyle}: a command you can override to style the page numbers. By default, they are centered on the page.}
\end{itemize}

If, for instance, you want to set page numbers in a different font you can redefine the command like so:

\begin{verbatim}
\line
\\define[command=foliostyle]\{\\center\{\\font[family=Albertus]\{\\process\}\}\}
\line
\end{verbatim}

If you want to put page numbers on the left side of even pages and the right side of odd pages, there are a couple of ways you can do that.
The complicated way is to define a command in Lua which inspects the page number and then sets the number ragged left or ragged right appropriately.
The easy way is just to put your folio frame where you want it on the master page...
\end{document}
]]

return package
