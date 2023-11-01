local lfs = require "lfs"
local toml = require 'toml'
local insp = require "inspect"
local datafile = require "datafile"

toml.strict = false -- to enable more lua-friendly features (like mixed arrays)

local function file(f)
  if io.open(f) ~= nil then
      return true
  else
      return false
  end
end

local function super(file, name, typeofreturn) --  parses toml files
  local raw

  if type(file) == "userdata" then
      raw = file:read("*all")
  elseif type(file) == "string" then
      raw = assert(io.open(tostring(file), "r")):read("*all")
  end

  if typeofreturn == "string" then -- to show it as verbatim in the documentation
      string.gsub(raw, "\n", "\n\n\n")
      return raw
  end

  local status
  local input, output = {}, {
      frames = {}
  }
  status, input = pcall(toml.parse, raw)

  if status then
    for i, j in pairs(input) do
      output[i] = j
    end
  end
  return output
end

function merge(fallback, localfile, count) -- it runs through both files and compare each item at the lowest level
  local T, count = fallback, count or 0

  if localfile == nil then
      return fallback
  end

  for key, value in pairs(fallback) do -- overwrites any value declared in the localfile
      if type(value) == "table" and localfile[key] then        
          T[key], count = merge(T[key], localfile[key], count)
      elseif localfile[key] and localfile[key] ~= "" then
          T[key] = localfile[key]
      else
          T[key] = fallback[key]
      end
      -- if key == "spacing" then print(insp(value)) end
  end
  
  -- print("COUNT: "..count)
  -- print(insp(T["spacing"]))

  for key, value in pairs(localfile) do -- writes anything else from localfile which is not in default
      if not fallback[key] then
          T[key] = value
      end
  end

  return T, count + 1
end

local function geToml()
  local home, config = os.getenv("HOME")
  local path = {
    datafile.open("config/default.toml", "r"),
    home .. "/.sile/default.toml",
    lfs.currentdir() .. "/settings.toml",
    home .. "/.sile/layouts/"
  }

  config = merge(super(path[1], "default"), super(path[2], "~/.sile/default"))
  config = merge(super(datafile.open("layouts/"..config.layout)), super(path[4]..config.layout..".toml"))

  if file(path[3]) then
    config = merge(config, super(path[3]))
  end
  
  -- print(insp(config))
  return config
end

return geToml
