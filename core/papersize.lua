local papersize = {
  letter = { 612, 792 },
  note = { 612, 792 },
  legal = { 612, 1008 },
  executive = { 522, 756 },
  halfletter = { 396, 612 },
  halfexecutive = { 378, 522 },
  statement = { 396, 612 },
  folio = { 612, 936 },
  quarto = { 610, 780 },
  ledger = { 1224, 792 },
  tabloid = { 792, 1224 },
  p1 = { 453.543, 651.969 }, -- 16 x 23 cm
  a0 = { 2383.9370337, 3370.3937373 },
  a1 = { 1683.7795457999998, 2383.9370337 },
  a2 = { 1190.551194, 1683.7795457999998 },
  a3 = { 841.8897728999999, 1190.551194 },
  a4 = { 595.275597, 841.8897728999999 },
  a5 = { 419.52756359999995, 595.275597 },
  a6 = { 297.6377985, 419.52756359999995 },
  a7 = { 209.76378179999998, 297.6377985 },
  a8 = { 147.40157639999998, 209.76378179999998 },
  a9 = { 104.88189089999999, 147.40157639999998 },
  a10 = { 73.70078819999999, 104.88189089999999 },
  b0 = { 2834.6457, 4008.1890197999996 },
  b1 = { 2004.0945098999998, 2834.6457 },
  b2 = { 1417.32285, 2004.0945098999998 },
  b3 = { 1000.6299320999999, 1417.32285 },
  b4 = { 708.661425, 1000.6299320999999 },
  b5 = { 498.89764319999995, 708.661425 },
  b6 = { 354.3307125, 498.89764319999995 },
  b7 = { 249.44882159999997, 354.3307125 },
  b8 = { 175.7480334, 249.44882159999997 },
  b9 = { 124.72441079999999, 175.7480334 },
  b10 = { 87.8740167, 124.72441079999999 },
  c2 = { 1298.2677305999998, 1836.8504136 },
  c3 = { 918.4252068, 1298.2677305999998 },
  c4 = { 649.1338652999999, 1003.4645777999999 },
  c5 = { 459.2126034, 649.1338652999999 },
  c6 = { 323.1496098, 459.2126034 },
  c7 = { 229.6063017, 323.1496098 },
  c8 = { 161.5748049, 229.6063017 },
  dl = { 311.81102699999997, 623.6220539999999 },
  comm10 = { 297, 684 },
  monarch = { 279, 540 },
  ansia = { 612, 792 },
  ansib = { 792, 1224 },
  ansic = { 1224, 1584 },
  ansid = { 1584, 2448 },
  ansie = { 2448, 3168 },
  arche = { 2592, 3456 },
  arche2 = { 1872, 2736 },
  arche3 = { 1944, 2808 },
  arche1 = { 2160, 3024 },
  archd = { 1728, 2592 },
  archc = { 1296, 1728 },
  archb = { 864, 1296 },
  archa = { 648, 864 },
  flsa = { 612, 936 },
  flse = { 612, 936 },
  csheet = { 1224, 1584 },
  dsheet = { 1584, 2448 },
  esheet = { 2448, 3168 }
}
-- ADD SUPPORT TO LANDSCAPE
setmetatable(papersize, {
  __call = function(self, size)
    local _, _, x, y = string.find(size, "(.+)%s+x%s+(.+)")
    if x and y then
      return { SILE.measurement(x):tonumber(), SILE.measurement(y):tonumber() }
    else
      size = string.lower(size:gsub("[-%s]+", ""))
      if self[size] then
        if SILE.scratch.styles.landscape then
          self[size][1], self[size][2] = self[size][2], self[size][1] -- Inverts the values in order to make it in landscape orientation
          return self[size]
        else
          return self[size]
        end
      end
    end
    SU.error(string.format([[Unable to parse papersize '%s'.
    Custom sizes may be entered with 'papersize=<measurement> x <measurement>'.
    Predefined paper sizes include: %s]],
      size, table.concat(pl.tablex.keys(papersize), ", ")))
  end
})

return papersize
