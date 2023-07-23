# extend.sile

**UNDER DEVELOPMENT!!!**

A bunch of changes and new packages for the SILE typesetting system I've making for personal use.

## Main concepts

Many styling options can be changed through a *settings.toml* file in the working directory, you just need declare the options you want overwrite in the same name as in *config/styles/default.toml*. For example, the default alignment for folios is center and the default color of the chapters names is black, but let us say you want to change only these two options:

``` toml
[alignments]
folio = "mirror"

[fonts]
chapters  = ["", "", "", "#c28e00"]
```

Note that the original statement in default.toml is `chapters  = ["Cormorant Infant",   "18pt", 700, false]`, but since in this case you would need to change only the last option, you must let all the previous blank.

## Requirements

I can't say if it works with older versions of SILE since I'm always using the latest one and won't waste my time testing it.  

- Luarocks
  - ftcsv
  - toml
  - inspect (for testing purposes)

Fonts:

- Baskervville
- Cormorant
- Cormorant SC
- Cormorant Garamond
- Cormorant Infant
- Cormorant Unicase
- Cormorant Upright
- Noto Sans JP  (for characters like ▩▤▧⌘)
