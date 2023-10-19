local toml  = require 'toml'
local insp  = require "inspect"

local folio = {
	bottom = "0",
	left = "0",
	right = "0",
	top = "0"
}

local super = function(path, typeofreturn)   --  parses toml files
	local file <close> = assert(io.open(tostring(path), "r"))

	local raw = file:read("*all")

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
		if input.frames then
			local i = 1

			for key, frameset in pairs(input.frames) do
				local first

				for firstF, _ in pairs(frameset) do
					if firstF == "content" or firstF == "author" or firstF == "first" then
						first = firstF
					end
				end

				output.frames[key] = {}
				output.frames[key].frameset = frameset
				output.frames[key].first = first

				if not frameset["folio"] then
					output.frames[key].frameset["folio"] = folio
				end

				i = i + 1
			end
		end
	else
		print("CANNOT OPEN: " .. path)
	end
	-- print(insp(output))
	return output
end


local function merge(localfile, fallback, count) -- it might run through both files and compare each item at the lowest level
  local T, count = fallback, count or 1

  -- print(inspect(fallback))
  -- print(count)

  if localfile == nil then
    return fallback
  end


  for key, value in pairs(fallback) do -- ove rwrites any value declared in the localfile
    if type(value) == "table" and localfile[key] then
      T[key], count = merge(localfile[key], T[key], count)
    elseif localfile[key] and localfile[key] ~= "" then
      -- print("key: " .. key .. "\nfallback: " .. value .. "\nlocalfile: " .. localfile[key])
      T[key] = localfile[key]
    else
      T[key] = fallback[key]
    end
  end

  for key, value in pairs(localfile) do -- writes anything else from localfile thats is not in default
    if not fallback[key] then
      T[key] = value
    end
  end

  return T, count + 1
end


return super
