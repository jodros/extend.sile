local lfs = require "lfs"
local toml = require 'toml'
local datafile = require "datafile"

toml.strict = false -- to enable more lua-friendly features (like mixed arrays)

local folio = {
    left = "0",
    right = "0",
    top = "0",
    bottom = "0"
}

local function fileExist(f)
    if io.open(f) ~= nil then
        return true
    else
        return false
    end
end

local function super(file, typeofreturn) --  parses toml files
    local raw

    if type(file) == "userdata" then
        raw = file:read("*all")
    elseif fileExist(file) and type(file) == "string" then
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
            if i == "frames" then
                for name, set in pairs(j) do
                    if not set.folio then
                        set.folio = folio
                    end
                end
            end
            output[i] = j
        end
    end

    return output
end

function merge(fallback, localfile, count) -- it runs through both files and compare each item at the lowest level
    local T, count = fallback, count or 0

    if localfile == nil or localfile == false then
        return fallback
    end

    for key, value in pairs(fallback) do -- overwrites any value declared in the localfile
        if type(value) == "table" and localfile[key] then
            T[key], count = merge(T[key], localfile[key], count)
        elseif localfile[key] and localfile[key] ~= "" then
            T[key] = localfile[key]
        elseif localfile[key] == nil then
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

local function geToml()

    local home, config, layoutConfig = os.getenv("HOME"), {}, {}
    local dotsile = home .. "/.config/sile/"
    local layoutPath = (config.layout or "generic") .. ".toml"
    local default = datafile.open("config/default.toml")
    local layout = datafile.open("config/layouts/" .. layoutPath)
    local locDefault = dotsile .. "default.toml"
    local locLayout = dotsile .. "layouts/" .. layoutPath
    local settings = lfs.currentdir() .. "/settings.toml"

    if not fileExist(dotsile) then
        lfs.mkdir(dotsile)
        os.execute("cp " .. datafile.path("config/default.toml") .. " " .. dotsile)
    elseif not fileExist(dotsile .. "layouts/") then
        lfs.mkdir(dotsile .. "layouts/")
        os.execute("cp " .. datafile.path("config/layouts/" .. layoutPath) .. " " .. dotsile .. "layouts/")
    end

    config = merge(super(default), super(locDefault))
    layoutConfig = merge(super(layout), super(locLayout))
    config = merge(config, layoutConfig)

    if fileExist(settings) then
        config = merge(config, super(settings))
    end

    return config
end

return geToml
