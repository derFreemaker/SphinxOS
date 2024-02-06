local Environment = require("OS.System.Threading.Environment")

---@class SphinxOS.System.Require
---@field package cache table<string, any[]>
---@field Searchers (fun(path: string) : string)[]
local Require = {
    cache = {},
    Searchers = {}
}
Require.cache["/OS/System/Require.lua"] = { Require }
Require.cache["/OS/System/Threading/Environment.lua"] = { Environment }

if NotInGame then
    return Require
end

---@param path string
function require(path)
    local env = Environment.Static__Current()
    if env and path:find("//") ~= 1 then
        path = filesystem.path(env.workingDirectory .. path)
    end
    path = path:gsub("//", "/")

    ---@type SphinxOS.System.FileSystem.Path[]
    local history = {}
    local found = false
    for _, func in pairs(Require.Searchers) do
        local tmp = func(path)
        table.insert(history, tmp)

        if filesystem.isFile(tmp) then
            path = tmp
            found = true
            break
        end
    end
    if not found then
        local errMsg = "unable to find file to require: '" .. path .. "'\n"
        for _, try in ipairs(history) do
            errMsg = errMsg .. try .. "\n"
        end
        error(errMsg)
    end

    local data = Require.cache[path]
    if data then
        return table.unpack(data)
    end

    data = { filesystem.doFile(path) }
    Require.cache[path] = data

    return table.unpack(data)
end

Require.Searchers[1] = function(path)
    return path
end

Require.Searchers[2] = function(path)
    return path .. ".lua"
end

Require.Searchers[3] = function(path)
    return path .. "/init.lua"
end

return Require
