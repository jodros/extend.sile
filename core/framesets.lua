local insp = require "inspect"

local nullfolio = {
  bottom = "0",
  left = "0",
  right = "0",
  top = "0"
}

local maxwidth, halfwidth, maxheight, halfheight = "100%pw", "50%pw", "100%ph", "50%ph"
local w, h, minus, plus = "%pw", "%ph", "-", "+"

local isolate = function(str)
  return "(" .. str .. ")"
end


local frames = {
  simple = {
    first = "content",
    frameset = {
      content = {
        left = "10%pw",
        right = "90%pw",
        top = "10%ph",
        bottom = "top(footnotes)"
      },
      folio = {
        left = "left(content)",
        right = "right(content)",
        top = "bottom(footnotes)+2%ph",
        bottom = "97%ph"
      },
      footnotes = {
        left = "left(content)",
        right = "right(content)",
        height = "0",
        bottom = "90%ph"
      }
    }
  },
  front = {
    first = "author",
    frameset = {
      author = {
        bottom = "30%ph",
        left = "20%pw",
        right = "80%pw",
        height = "0"
      },
      imprint = {
        bottom = "85%ph",
        left = "20%pw",
        right = "80%pw",
        height = "0"
      },
      title = {
        bottom = "45%ph",
        height = "0",
        left = "20%pw",
        right = "80%pw"
      }
    }
  },
  max = {
    first = "content",
    frameset = {
      content = {
        bottom = pheight,
        left = "0",
        right = pwidth,
        top = "0"
      },
      folio = nullfolio
    }
  },
  maxrotated = {
    first = "content",
    frameset = {
      content = {
        bottom = "300%ph",
        left = "0",
        right = "300%pw",
        rotate = "45",
        top = "-300%ph"
      },
      folio = nullfolio
    }
  },
  right = {
    first = "content",
    frameset = {
      content = {
        bottom = "top(footnotes)-1%ph",
        left = "(100%pw-50%ph)/2",
        right = "100%pw-((100%pw-50%ph)/2)",
        top = "(100%ph-100%pw)/2"
      },
      folio = {
        bottom = "bottom(footnotes)+5%ph",
        left = "left(content)",
        right = "right(content)",
        top = "bottom(footnotes)+3%ph"
      },
      footnotes = {
        bottom = "90%ph",
        height = "0",
        left = "left(content)",
        right = "right(content)"
      },
      runningHead = {
        bottom = "top(content)-3%ph",
        left = "3.4cm",
        right = "100%pw-2cm",
        top = "1.5cm"
      }
    }
  },
  toc = {
    first = "content",
    frameset = {
      content = {
        bottom = "100%ph-((100%ph-100%pw)/2)",
        left = "20%pw",
        right = "80%pw",
        top = "(100%ph-100%pw)/2"
      },
      folio = nullfolio
    }
  },
}

local frameset = {}
local l, r, t, b, distance = 0, 50, 0, 50, 5
local halfdistance = distance / 2

frameset.first = {
  left   = distance .. w,
  right  = r .. w .. minus .. halfdistance .. w,
  top    = distance .. w,
  bottom = b .. h .. minus .. halfdistance .. w,
  next   = "second"
}

frameset.second = {
  left   = isolate(frameset.first.right) .. plus .. distance .. w,
  right  = maxwidth .. minus .. distance .. w,
  top    = frameset.first.top,
  bottom = frameset.first.bottom,
  next   = "third"
}

frameset.third = {
  left   = frameset.first.left,
  right  = frameset.first.right,
  top    = isolate(frameset.first.bottom) .. plus .. distance .. w,
  bottom = maxheight .. minus .. distance .. w,
  next   = "fourth"
}

frameset.fourth = {
  left   = frameset.second.left,
  right  = frameset.second.right,
  top    = frameset.third.top,
  bottom = frameset.third.bottom
}

frameset.folio = nullfolio

-- print(insp(frameset))

frames.four = {
  first = "first",
  frameset = frameset
}

-- frames.abnt = {
--   cover = {
--     first = "author",
--     frameset = {
--       author = {
--         bottom = "30%ph",
--         left = "0%pw",
--         right = "80%pw",
--         top = "20%ph"
--       },
--       imprint = {
--         bottom = "85%ph",
--         left = "0%pw",
--         right = "80%pw",
--         top = "80%ph"
--       },
--       title = {
--         bottom = "45%ph",
--         height = "0",
--         left = "0",
--         right = "80%pw"
--       }
--     }
--   },
--   main = {
--     first = "content",
--     frameset = {
--       content = {
--         bottom = "top(footnotes)-5%ph",
--         left = "(100%pw-50%ph)/2",
--         right = "100%pw-((100%pw-50%ph)/2)",
--         top = "(100%ph-100%pw)/2"
--       },
--       folio = {
--         bottom = "bottom(footnotes)+5%ph",
--         left = "left(content)",
--         right = "right(content)",
--         top = "bottom(footnotes)+3%ph"
--       },
--       footnotes = {
--         bottom = "90%ph",
--         height = "0",
--         left = "left(content)",
--         right = "right(content)"
--       },
--       runningHead = {
--         bottom = "top(content)-3%ph",
--         left = "3.4cm",
--         right = "100%pw-2cm",
--         top = "1.5cm"
--       }
--     }
--   }
-- }


return frames
