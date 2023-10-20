local lfs   = require "lfs"
local toml  = require 'toml'
local insp  = require "inspect"
local datafile = require "datafile"

local folio = {
	bottom = "0",
	left = "0",
	right = "0",
	top = "0"
}

local gatherer = {}

function gatherer.super(file, typeofreturn)   --  parses toml files
  local raw

  if type(file) == "userdata" then
  elseif type(file) == "string" then
    raw = assert(io.open(tostring(file), "r")):read("*all")
  end

	if typeofreturn == "string" then -- to show it as verbatim in the documentation
		string.gsub(raw, "\n", "\n\n\n")
		return raw
	end

	local status
	local input, output = {}, { frames = {} }
	status, input = pcall(toml.decode, raw)

	if status then
		for i, j in pairs(input) do
			if j ~= input.frame then
				output[i] = j
			end
		end
	else
		print("CANNOT OPEN: " .. file)
	end
	return output
end

function gatherer.geToml()
  local home = os.getenv("HOME")
  local path = {
    datafile.open("default.toml"),
    home .. "/.sile/default.toml",
    --datafile.open(layouts/),
    --home .. "/.sile/layouts/"
    lfs.currentdir() .. "/settings.toml"
  }
end

function gatherer.merge(fallback, localfile, count) -- it runs through both files and compare each item at the lowest level
  local T, count = fallback, count or 1

  if localfile == nil then
    return fallback
  end

  for key, value in pairs(fallback) do -- overwrites any value declared in the localfile
    if type(value) == "table" and localfile[key] then
      T[key], count = gatherer.merge(T[key], localfile[key], count)
    elseif localfile[key] and localfile[key] ~= "" then
      T[key] = localfile[key]
    else
      T[key] = fallback[key]
    end
  end

  for key, value in pairs(localfile) do -- writes anything else from localfile which is not in default
    if not fallback[key] then
      T[key] = value
    end
  end

  return T, count + 1
end

return gatherer
