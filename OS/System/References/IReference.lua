---@class SphinxOS.System.References.IReference<TReference> : object, { Get: fun() : TReference }
---@field protected m_obj Satisfactory.Components.Object?
---@field m_expires number
---@overload fun() : SphinxOS.System.References.IReference
local IReference = {}

IReference.m_expires = 0

---@return any
function IReference:Get()
    if self.m_expires < computer.millis() then
        if not self:Fetch() then
            return nil
        end

        --//TODO: get refresh delay from some kind of config
        self.m_expires = computer.millis() + 60000 -- Config.REFERENCE_REFRESH_DELAY
    end

    return self.m_obj
end

---@return boolean found
function IReference:Fetch()
    ---@diagnostic disable-next-line
end

IReference.Fetch = Utils.Class.IsAbstract

---@return boolean isValid
function IReference:Check()
    return self:Get() == nil
end

return Utils.Class.Create(IReference, "SphinxOS.System.References.IReference", nil, { IsAbstract = true })
