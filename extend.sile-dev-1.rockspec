package = "extend.sile"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/jodros/extend.sile.git"
}
description = {
   homepage = "blog.jodros.xyz/extending-sile",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "inspect",
   "ftcsv",
   "toml"
}
build = {
   type = "builtin",
   modules = {
      ["sile.classes.base"]                  = "classes/base.lua",
      ["sile.classes.plain"]                 = "classes/plain.lua",

      ["sile.aux.super"]                     = "aux/super.lua",
      ["sile.aux.report"]                    = "aux/report.lua",
      -- ["sile.aux.orthography"]               = "aux/orthography.lua",
      ["sile.aux.transliteration"]           = "aux/transliteration.lua",
      ["sile.core.sile"]                     = "core/sile.lua",
      ["sile.core.font"]                     = "core/font.lua",
      ["sile.core.framesets"]                = "core/framesets.lua",
      ["sile.core.settings"]                 = "core/settings.lua",
      ["sile.core.papersize"]                = "core/papersize.lua",

      ["sile.packages.abnt.init"]            = "packages/abnt/init.lua",
      ["sile.packages.folio.init"]           = "packages/folio/init.lua",
      ["sile.packages.styles.init"]          = "packages/styles/init.lua",
      ["sile.packages.textual.init"]         = "packages/textual/init.lua",
      ["sile.packages.dropcaps.init"]        = "packages/dropcaps/init.lua",
      ["sile.packages.footnotes.init"]       = "packages/footnotes/init.lua",
      ["sile.packages.frametricks.init"]     = "packages/frametricks/init.lua",
      ["sile.packages.extra-textual.init"]   = "packages/extra-textual/init.lua",
      ["sile.packages.tableofcontents.init"] = "packages/tableofcontents/init.lua",

      ["sile.typesetters.base"]              = "typesetters/base.lua",
   },
   copy_directories = { "config" }
}
