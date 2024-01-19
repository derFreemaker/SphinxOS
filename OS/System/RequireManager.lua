---@type table<string, any[]>
local cache = {}

---@class SphinxOS.System.RequireManager
---@field workingDirectory string
local RequireManager = {
    workingDirectory = "/"
}

---@param path string
function RequireManager:SetWorkingDirectory(path)
    self.workingDirectory = path
end

---@param path string
function require(path)
    if not path:find("//") then
        path = filesystem.path(RequireManager.workingDirectory, path:gsub("//", "/"))
    end

    local data = cache[path]
    if data then
        return table.unpack(data)
    end

    if not filesystem.isFile(path) then
        path = path .. ".lua"
    end

    if not filesystem.isFile(path) then
        return nil
    end

    data = { filesystem.loadFile(path)() }
    cache[path] = cache

    return table.unpack(data)
end

return RequireManager
