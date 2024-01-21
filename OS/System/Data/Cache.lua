---@generic T
---@class SphinxOS.System.Data.Cache<T> : { m_cache: { [string|integer]: T }, Add : (fun(self: SphinxOS.System.Data.Cache<T>, index: string | integer, value: T)), Get : (fun(self: SphinxOS.System.Data.Cache<T>, index: string |integer) : T), TryGet : (fun(self: SphinxOS.System.Data.Cache<T>, index: string |integer) : boolean, T) }, object
---@field m_cache table<string|integer, any>
---@overload fun(): SphinxOS.System.Data.Cache
local Cache = {}

function Cache:__init()
    self.m_cache = setmetatable({}, { __mode = "v" })
end

---@generic T : any
---@param index string | integer
---@param value T
function Cache:Add(index, value)
    self.m_cache[index] = value
end

---@generic T : any
---@param index string | integer
---@return T
function Cache:Get(index)
    local value = self.m_cache[index]
    if not value then
        error("no value found with idOrIndex: " .. index)
    end

    return value
end

---@generic T : any
---@param index string | integer
---@return boolean, T
function Cache:TryGet(index)
    local value = self.m_cache[index]
    if not value then
        return false, nil
    end

    return true, value
end

return Utils.Class.Create(Cache, "SphinxOS.System.Data.Cache")
