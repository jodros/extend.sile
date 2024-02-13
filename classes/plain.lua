local base = require("classes.base")

local class = pl.class(base)
class._name = "plain"

class.defaultFrameset = SILE.scratch.styles.frames.right
class.firstContentFrame = "content"

local skips = {
    small = "3pt plus 1pt minus 1pt",
    med = "6pt plus 2pt minus 2pt",
    big = "12pt plus 4pt minus 4pt"
}

local packlist = { "autodoc", "background", "bibtex", "color", "color-fonts", "converters", "counters", "features","font-fallback", "extend.footnotes", "extend.frametricks", "extend.tableofcontents", "extend.folio","image", "indexer", "linespacing", "lorem", "pdf", "url", "unichar", "lists", "rotate", "textual", "styles", "extra-textual", "graphic" }
--    "barcodes.ean13",
--    "qrcode",
--    "printoptions"

function class:_init(options)
    options = options or {}
    base._init(self, options)

    self:loadPackage("bidi")
    -- self:loadPackage("extend.folio")
    self:loadPackage("masters")

    for key, value in pairs(SILE.scratch.styles.frames) do
        self:defineMaster({
            id = key,
            firstContentFrame = "content" or "first",
            frames = value
        })
    end

    for _, package in ipairs(packlist) do
        self:loadPackage(package)
    end

    self:loadPackage("twoside", {
        oddPageMaster = "right",
        evenPageMaster = "left"
    })

    if self:currentMaster() == "right" then
        self:mirrorMaster("right", "left")
    end
end

function class:declareOptions()
    base.declareOptions(self)
    self:declareOption("direction", function(_, value)
        if value then
            SILE.documentState.direction = value
            SILE.settings:set("font.direction", value, true)
            for _, frame in pairs(self.defaultFrameset) do
                if not frame.direction then
                    frame.direction = value
                end
            end
        end
        return SILE.documentState.direction
    end)

    -- self:declareOption("layout", function(_, value)
    --     if value then
    --         self.layout = value
    --     end
    --     return self.layout
    -- end)
end

function class:setOptions(options)
    -- TODO: set a default direction here?
    options.papersize = options.papersize or SILE.scratch.styles.papersize
    options.landscape = options.landscape or SILE.scratch.styles.landscape
    base.setOptions(self, options)
end

function class:declareSettings()
    base.declareSettings(self)
    for k, v in pairs(skips) do
        SILE.settings:declare({
            parameter = "plain." .. k .. "skipamount",
            type = "vglue",
            default = SILE.nodefactory.vglue(v),
            help = "The amount of a \\" .. k .. "skip"
        })
    end
end

function class:registerCommands()
    SILE.classes.base.registerCommands(self)

    self:registerCommand("noindent", function(_, content)
        if #SILE.typesetter.state.nodes ~= 0 then
            SU.warn(
                "\\noindent called after nodes already recieved in a paragraph, the setting will have no effect because the parindent (if any) has already been output")
        end
        SILE.settings:set("current.parindent", SILE.nodefactory.glue())
        SILE.process(content)
    end, "Do not add an indent to the start of this paragraph")

    self:registerCommand("neverindent", function(_, content)
        SILE.settings:set("current.parindent", SILE.nodefactory.glue())
        SILE.settings:set("document.parindent", SILE.nodefactory.glue())
        SILE.process(content)
    end, "Turn off all indentation")

    self:registerCommand("indent", function(_, content)
        SILE.settings:set("current.parindent", SILE.settings:get("document.parindent"))
        SILE.process(content)
    end, "Do add an indent to the start of this paragraph, even if previously told otherwise")

    for k, _ in pairs(skips) do
        self:registerCommand(k .. "skip", function(_, _)
            SILE.typesetter:leaveHmode()
            SILE.typesetter:pushExplicitVglue(SILE.settings:get("plain." .. k .. "skipamount"))
        end, "Skip vertically by a " .. k .. " amount")
    end

    self:registerCommand("hfill", function(_, _)
        SILE.typesetter:pushExplicitGlue(SILE.nodefactory.hfillglue())
    end, "Add a huge horizontal glue")

    self:registerCommand("vfill", function(_, _)
        SILE.typesetter:leaveHmode()
        SILE.typesetter:pushExplicitVglue(SILE.nodefactory.vfillglue())
    end, "Add huge vertical glue")

    self:registerCommand("hss", function(_, _)
        SILE.typesetter:initline()
        SILE.typesetter:pushGlue(SILE.nodefactory.hssglue())
        table.insert(SILE.typesetter.state.nodes, SILE.nodefactory.zerohbox())
    end, "Add glue which stretches and shrinks horizontally (good for centering)")

    self:registerCommand("vss", function(_, _)
        SILE.typesetter:pushExplicitVglue(SILE.nodefactory.vssglue())
    end, "Add glue which stretches and shrinks vertically")

    local _thinspacewidth = SILE.measurement(0.16667, "em")

    self:registerCommand("thinspace", function(_, _)
        SILE.call("glue", {
            width = _thinspacewidth
        })
    end)

    self:registerCommand("negthinspace", function(_, _)
        SILE.call("glue", {
            width = -_thinspacewidth
        })
    end)

    self:registerCommand("enspace", function(_, _)
        SILE.call("glue", {
            width = SILE.measurement(1, "en")
        })
    end)

    self:registerCommand("relax", function(_, _)
    end)

    self:registerCommand("enskip", function(_, _)
        SILE.call("enspace")
    end)

    local _quadwidth = SILE.measurement(1, "em")

    self:registerCommand("quad", function(_, _)
        SILE.call("glue", {
            width = _quadwidth
        })
    end)

    self:registerCommand("qquad", function(_, _)
        SILE.call("glue", {
            width = _quadwidth * 2
        })
    end)

    self:registerCommand("slash", function(_, _)
        SILE.typesetter:typeset("/")
        SILE.call("penalty", {
            penalty = 50
        })
    end)

    self:registerCommand("break", function(_, _)
        SILE.call("penalty", {
            penalty = -10000
        })
    end, "Requests a frame break (if in vertical mode) or a line break (if in horizontal mode)")

    self:registerCommand("cr", function(_, _)
        SILE.call("hfill")
        SILE.call("break")
    end, "Fills a line with a stretchable glue and then requests a line break")

    -- Despite their name, in older versions, \framebreak and \pagebreak worked badly in horizontal
    -- mode. The former was a linebreak, and the latter did nothing. That was surely not intended.
    -- There are many ways, though to assume what's wrong or what the user's intent ought to be.
    -- We now warn, and terminate the paragraph, but to all extents this might be a wrong approach to
    -- reconsider at some point.

    self:registerCommand("framebreak", function(_, _)
        if not SILE.typesetter:vmode() then
            SU.warn("framebreak was not intended to work in horizontal mode. Behaviour may change in future versions")
        end
        SILE.call("penalty", {
            penalty = -10000,
            vertical = true
        })
    end, "Requests a frame break (switching to vertical mode if needed)")

    self:registerCommand("pagebreak", function(_, _)
        if not SILE.typesetter:vmode() then
            SU.warn("pagebreak was not intended to work in horizontal mode. Behaviour may change in future versions")
        end
        SILE.call("penalty", {
            penalty = -20000,
            vertical = true
        })
    end, "Requests a non-negotiable page break (switching to vertical mode if needed)")

    self:registerCommand("nobreak", function(_, _)
        SILE.call("penalty", {
            penalty = 10000
        })
    end, "Inhibits a frame break (if in vertical mode) or a line break (if in horizontal mode)")

    self:registerCommand("novbreak", function(_, _)
        SILE.call("penalty", {
            penalty = 10000,
            vertical = true
        })
    end, "Inhibits a frame break (switching to vertical mode if needed)")

    self:registerCommand("allowbreak", function(_, _)
        SILE.call("penalty", {
            penalty = 0
        })
    end,
        "Allows a page break (if in vertical mode) or a line break (if in horizontal mode) at a point would not be considered as suitable for breaking")

    -- THIS SEEMS BROKEN BUT THE COMMAND NOT MENTIONED IN THE SILE MANUAL
    -- In TeX, "\filbreak" compensates the vertical fill if no break actually occurs
    -- (\def\filbreak{\par\vfil\penalty-200\vfilneg)
    self:registerCommand("filbreak", function(_, _)
        SILE.call("vfill")
        SILE.call("penalty", {
            penalty = -200
        })
    end, "I HAVE THE SAME NAME AS A TEX COMMAND BUT DON'T SEEM TO BE THE SAME")

    -- NOTE: TeX's "\goodbreak" does a \par first, so always switches to vertical mode.
    -- SILE differs here, allowing it both within a paragraph (line breaking) and between
    -- paragraphs (page breaking).
    self:registerCommand("goodbreak", function(_, _)
        SILE.call("penalty", {
            penalty = -500
        })
    end, "Indicates a good potential point to break a frame (if in vertical mode) or a line (if in horizontal mode")

    self:registerCommand("eject", function(_, _)
        SILE.call("vfill")
        SILE.call("break")
    end, "Fills the page with stretchable vglue and then request a page break")

    self:registerCommand("supereject", function(_, _)
        SILE.call("vfill")
        SILE.call("penalty", {
            penalty = -20000
        })
    end, "Fills the page with stretchable vglue and then requests a non-negotiable page break")

    self:registerCommand("justified", function(_, content)
        SILE.settings:set("document.rskip", nil)
        SILE.settings:set("document.spaceskip", nil)
        SILE.process(content)
        SILE.call("par")
    end)

    self:registerCommand("rightalign", function(_, content)
        SILE.call("raggedleft", {}, function()
            SILE.process(content)
            SILE.call("par")
        end)
    end)

    self:registerCommand("em", function(_, content)
        SILE.call("font", {
            style = "Italic"
        }, content)
    end)

    self:registerCommand("strong", function(_, content)
        SILE.call("font", {
            weight = 700
        }, content)
    end)

    self:registerCommand("code", function(options, content)
        -- IMPLEMENTATION NOTE:
        -- The \code command came from the url package, though used in plenty of
        -- places. It was referring to the verbatim:font from the verbatim
        -- package, which _should_ be sort of unrelated.
        -- Trying to untangle the things here, by introducing the
        -- definition from the former, but it's of sub-quality...
        -- The ugly -3 size is a HACK of sorts.
        options.family = options.family or "Hack"
        options.size = options.size or SILE.settings:get("font.size") - 3
        SILE.call("font", options, content)
    end)

    self:registerCommand("nohyphenation", function(_, content)
        SILE.call("font", {
            language = "und"
        }, content)
    end)

    self:registerCommand("raggedright", function(_, content)
        SILE.call("ragged", {
            right = true
        }, content)
    end)

    self:registerCommand("raggedleft", function(_, content)
        SILE.call("ragged", {
            left = true
        }, content)
    end)

    self:registerCommand("quote", function(_, content)
        SU.deprecated("\\quote", "\\pullquote", "0.14.5", "0.16.0", [[
  The \quote command has *such* bad output it is being completely
  deprecated as unsuitable for general purpose use. The pullquote
  package (\use[module=packages.pullquote]) provides one alternative,
  but you can also copy and adapt the original source from the plain
  class if you need to maintain exact output past SILE v0.16.0.]])
        SILE.call("smallskip")
        SILE.call("par")
        local margin = SILE.measurement(2.5, "em")
        SILE.settings:set("document.lskip", margin)
        SILE.settings:set("document.lskip", margin)
        SILE.call("font", {
            size = SILE.measurement(0.8, "em")
        }, function()
            SILE.call("noindent")
            SILE.process(content)
        end)
        SILE.call("par")
        SILE.settings:set("document.lskip", nil)
        SILE.settings:set("document.rskip", nil)
        SILE.call("smallskip")
    end)

    self:registerCommand("listitem", function(_, content)
        SU.deprecated("\\listitem", "\\item", "0.14.6", "0.16.0", [[
  The new list package (\use[module=packages.lists) has much better
  typography for lists. If you want to maintain the exact output of listitem
  past SILE v0.16.0 copy the source of \listitem from the plain class into
  your project.]])
        SILE.call("medskip")
        SILE.typesetter:typeset("• ")
        SILE.process(content)
        SILE.call("medskip")
    end)

    self:registerCommand("sloppy", function(_, _)
        SILE.settings:set("linebreak.tolerance", 9999)
    end)

    self:registerCommand("awful", function(_, _)
        SILE.settings:set("linebreak.tolerance", 10000)
    end)

    self:registerCommand("center", function(_, content)
        if #SILE.typesetter.state.nodes ~= 0 then
            SU.warn("\\center environment started after other nodes in a paragraph, may not center as expected")
        end
        SILE.settings:temporarily(function()
            SILE.settings:set("current.parindent", 0)
            SILE.settings:set("document.parindent", 0)
            SILE.call("ragged", {
                left = true,
                right = true
            }, content)
        end)
    end)

    self:registerCommand("ragged", function(options, content)
        SILE.settings:temporarily(function()
            if SU.boolean(options.left, false) then
                SILE.settings:set("document.lskip", SILE.nodefactory.hfillglue())
            end
            if SU.boolean(options.right, false) then
                SILE.settings:set("document.rskip", SILE.nodefactory.hfillglue())
            end
            SILE.settings:set("typesetter.parfillskip", SILE.nodefactory.glue())
            SILE.settings:set("document.parindent", SILE.nodefactory.glue())
            SILE.settings:set("document.spaceskip", SILE.length("1spc", 0, 0))
            SILE.process(content)
            SILE.call("par")
        end)
    end)

    self:registerCommand("hbox", function(_, content)
        local hbox, hlist = SILE.typesetter:makeHbox(content)
        SILE.typesetter:pushHbox(hbox)
        if #hlist > 0 then
            SU.warn("Hbox has migrating content (ignored for now, but likely to break in future versions)")
            -- Ugly shim:
            -- One day we ought to do SILE.typesetter:pushHlist(hlist) here, so as to push
            -- back the migrating contents from within the hbox'ed content.
            -- However, old Lua code assumed the hbox to be returned, and sometimes removed it
            -- from the typesetter queue (for measuring, etc.), assuming it was the last
            -- element in the queue...
        end
        return hbox
    end, "Compiles all the enclosed horizontal-mode material into a single hbox")

    self:registerCommand("vbox", function(options, content)
        local vbox
        SILE.settings:temporarily(function()
            if options.width then
                SILE.settings:set("typesetter.breakwidth", SILE.length(options.width))
            end
            SILE.typesetter:pushState()
            SILE.process(content)
            SILE.typesetter:leaveHmode(1)
            vbox = SILE.pagebuilder:collateVboxes(SILE.typesetter.state.outputQueue)
            SILE.typesetter:popState()
        end)
        return vbox
    end, "Compiles all the enclosed material into a single vbox")
end

return class
