local base = require("packages.base")
local insp = require"inspect"


local package = pl.class(base)
package._name = "tableofcontents"

if not SILE.scratch._tableofcontents then
    SILE.scratch._tableofcontents = {}
end

local toc_used = false

function package:moveTocNodes()
    local node = SILE.scratch.info.thispage.toc
    if node then
        for i = 1, #node do
            node[i].pageno = self.packages.counters:formatCounter(SILE.scratch.counters.folio)
            table.insert(SILE.scratch.tableofcontents, node[i])
        end
    end
end

function package.writeToc(_)
    local tocdata = pl.pretty.write(SILE.scratch.tableofcontents)
    local tocfile, err = io.open(pl.path.splitext(SILE.input.filenames[1]) .. '.toc', "w")
    if not tocfile then
        return SU.error(err)
    end
    tocfile:write("return " .. tocdata)
    tocfile:close()

    if toc_used and not pl.tablex.deepcompare(SILE.scratch.tableofcontents, SILE.scratch._tableofcontents) then
        SU.msg("Notice: the table of contents has changed, please rerun SILE to update it.")
    end
end

function package.readToc(_)
    if SILE.scratch._tableofcontents and #SILE.scratch._tableofcontents > 0 then
        -- already loaded
        return SILE.scratch._tableofcontents
    end
    local tocfile, _ = io.open(pl.path.splitext(SILE.input.filenames[1]) .. '.toc')
    if not tocfile then
        return false -- No TOC yet
    end
    local doc = tocfile:read("*all")
    local toc = assert(load(doc))()
    SILE.scratch._tableofcontents = toc
    return SILE.scratch._tableofcontents
end

local function _linkWrapper(dest, func)
    if dest and SILE.Commands["pdf:link"] then
        return function()
            SILE.call("pdf:link", {
                dest = dest
            }, func)
        end
    else
        return func
    end
end

-- Flatten a node list into just its string representation.
-- (Similar to SU.contentToString(), but allows passing typeset
-- objects to functions that need plain strings).
local function _nodesToText(nodes)
    -- A real interword space width depends on several settings (depending on variable
    -- spaces being enabled or not, etc.), and the computation below takes that into
    -- account.
    local iwspc = SILE.shaper:measureSpace(SILE.font.loadDefaults({}))
    local iwspcmin = (iwspc.length - iwspc.shrink):tonumber()

    local string = ""
    for i = 1, #nodes do
        local node = nodes[i]
        if node.is_nnode or node.is_unshaped then
            string = string .. node:toText()
        elseif node.is_glue or node.is_kern then
            -- What we want to avoid is "small" glues or kerns to be expanded as full
            -- spaces.
            -- Comparing them to half of the smallest width of a possibly shrinkable
            -- interword space is fairly fragile and empirical: the content could contain
            -- font changes, so the comparison is wrong in the general case.
            -- It's a simplistic approach. We cannot really be sure what a "space" meant
            -- at the point where the kern or glue got absolutized.
            if node.width:tonumber() > iwspcmin * 0.5 then
                string = string .. " "
            end
        elseif not (node.is_zerohbox or node.is_migrating) then
            -- Here, typically, the main case is an hbox.
            -- Even if extracting its content could be possible in some regular cases
            -- we cannot take a general decision, as it is a versatile object  and its
            -- outputYourself() method could moreover have been redefined to do fancy
            -- things. Better warn and skip.
            SU.warn("Some content could not be converted to text: " .. node)
        end
    end
    -- Trim leading and trailing spaces, and simplify internal spaces.
    return pl.stringx.strip(string):gsub("%s%s+", " ")
end

if not SILE.scratch.pdf_destination_counter then
    SILE.scratch.pdf_destination_counter = 1
end

function package:_init()
    base._init(self)
    if not SILE.scratch.tableofcontents then
        SILE.scratch.tableofcontents = {}
    end
    self:loadPackage("infonode")
    self:loadPackage("leaders")
    self.class:registerHook("endpage", self.moveTocNodes)
    self.class:registerHook("finish", self.writeToc)
    self:deprecatedExport("writeToc", self.writeToc)
    self:deprecatedExport("moveTocNodes", self.moveTocNodes)
end

function package:registerCommands()
  self:registerCommand("tableofcontents", function (options, content)
    local linking = SU.boolean(options.linking, true)
    local toc = self:readToc()
    
    SILE.call("align", { item = "toc" }, function ()
        SILE.call("font:chapters", {}, function ()
            SILE.call("par")
           if not content[1] then
               SILE.call("fluent", {}, { "tableofcontents-title" })
           else
               SILE.process(content)
           end
        end)   
    end)

    SILE.call("skip", { height = "4%ph" })
    
    SILE.settings:temporarily(function ()
        SILE.settings:set("typesetter.parfillskip", SILE.nodefactory.glue())
        for _, item in ipairs(toc) do
            SILE.call("font:toc", {}, _linkWrapper(linking and item.link, function ()
              SILE.process(item.label)
              SILE.typesetter:typeset(" " .. item.pageno)
            end))
            SILE.call("medskip")
        end
    end)
  end)

  self:registerCommand("tocentry", function (options, content)
    local dest
    if SILE.Commands["pdf:destination"] then
      dest = "dest" .. tostring(SILE.scratch.pdf_destination_counter)
      SILE.call("pdf:destination", { name = dest })
      SILE.typesetter:pushState()
      SILE.process(content)
      local title = _nodesToText(SILE.typesetter.state.nodes)
      SILE.typesetter:popState()
      SILE.call("pdf:bookmark", { title = title, dest = dest, level = options.level })
      SILE.scratch.pdf_destination_counter = SILE.scratch.pdf_destination_counter + 1
    end
    SILE.call("info", {
      category = "toc",
      value = {
        label = SU.stripContentPos(content),
        level = (options.level or 1),
        number = options.number,
        link = dest
      }
    })
  end)
end

package.documentation = [[
\begin{document}
The \autodoc:package{tableofcontents} package provides ...
\end{document}
]]

return package
