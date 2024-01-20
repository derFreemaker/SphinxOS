---@class SphinxOS.System.Require
---@field package workingDirectory string
---@field package cache table<string, any[]>
---@field Searchers (fun(path: string) : string)[]
local Require = {
    cache = {},
    workingDirectory = "",
    Searchers = {}
}
Require.cache["/OS/System/Require.lua"] = { Require }

---@param path string?
function Require.SetWorkingDirectory(path)
    if not path or path == "/" then
        path = ""
    end

    Require.workingDirectory = filesystem.path(path)
end

---@param path string
function require(path)
    if path:find("//") ~= 1 then
        path = Require.workingDirectory .. path
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

    data = { filesystem.loadFile(path)() }
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
