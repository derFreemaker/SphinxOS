local cache = {}

---@param path string
---@return any ...
function require(path)
    local data = cache[path]
    if data then
        return table.unpack(data)
    end

    path = path .. ".lua"
    if not filesystem.isFile(path) then
        return nil
    end

    data = { filesystem.loadFile(path)() }
    cache[path] = cache
    return table.unpack(data)
end

Utils = require("/misc/utils")
