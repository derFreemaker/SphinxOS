---@class SphinxOS.System.References.ProxyReference<T> : SphinxOS.System.References.IReference<T>
---@field m_id FIN.UUID
---@overload fun(id: FIN.UUID) : SphinxOS.System.References.ProxyReference
local ProxyReference = {}

---@private
---@param id FIN.UUID
function ProxyReference:__init(id)
    self.m_id = id
end

function ProxyReference:Fetch()
    local obj = component.proxy(self.m_id)
    self.m_obj = obj
    return obj ~= nil
end

return Utils.Class.Create(ProxyReference, "SphinxOS.System.References.ProxyReference", {
    BaseClass = require("//OS/System/References/IReference")
})
