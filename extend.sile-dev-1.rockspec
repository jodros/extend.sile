package = "extend.sile"
version = "dev-1"
source = {
    url = "git+ssh://git@github.com/jodros/extend.sile.git"
}
description = {
    homepage = "jodros.github.io/extending-sile",
    license = "MIT"
}
dependencies = {"lua >= 5.1", "inspect", "datafile", "lua-toml"}
build = {
    type = "builtin",
    modules = {
        --    ["sile.classes.base"]                = "classes/base.lua",
        ["sile.classes.plain"] = "classes/plain.lua",

        ["sile.core.gatherer"] = "core/gatherer.lua",
        ["sile.core.sile"] = "core/sile.lua",
        ["sile.core.font"] = "core/font.lua",
        ["sile.core.papersize"] = "core/papersize.lua",

        ["sile.packages.styles.init"] = "packages/styles/init.lua",
        ["sile.packages.textual.init"] = "packages/textual/init.lua",
        ["sile.packages.extra-textual.init"] = "packages/extra-textual/init.lua",

        ["sile.packages.extend.folio.init"] = "packages/extend/folio/init.lua"
        --     ["sile.packages.footnotes.init"]       = "packages/footnotes/init.lua",
        --     ["sile.packages.tableofcontents.init"] = "packages/tableofcontents/init.lua",

        --    ["sile.typesetters.base"]              = "typesetters/base.lua",
    },
    copy_directories = {"config"}
}
