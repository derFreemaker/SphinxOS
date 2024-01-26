---@class SphinxOS.System.IAdapter : object
---@field protected m_hash integer?
---@field protected m_ref SphinxOS.System.References.IReference<Satisfactory.Components.Object>
local IAdapter = {}

-- ---@private
-- ---@deprecated
-- ---@param key any
-- function IAdapter:__index(key)
--     local obj = self.m_ref:Get()
--     local value = obj[key]

--     if not value then
--         return nil
--     end

--     if type(value) == "function" then
--         return function(...)
--             return value(self.m_ref:Get(), ...)
--         end
--     end

--     return value
-- end

---@return integer
function IAdapter:GetHashCode()
    if self.m_hash then
        return self.m_hash
    end

    self.m_hash = self.m_ref:Get():getHash()
    return self.m_hash
end

return Utils.Class.Create(IAdapter, "SphinxOS.System.IAdapter", { IsAbstract = true })
