local cache = {}

---@param path string
---@return any ...
function require(path)
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

---@class Freemaker.Utils
Utils = require("/OS/misc/utils")
Utils.Class = require("/OS/misc/classSystem")
