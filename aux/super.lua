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

return super
