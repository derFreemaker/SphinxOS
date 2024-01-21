---@class SphinxOS.System.Net.IPAddress : SphinxOS.System.Json.Serializable
---@field private m_address FIN.UUID
---@overload fun(address: string) : SphinxOS.System.Net.IPAddress
local IPAddress = {}

---@private
---@param address FIN.UUID
function IPAddress:__init(address)
    self:Raw__ModifyBehavior(function(modify)
        modify.CustomIndexing = false
    end)

    self.m_address = address

    self:Raw__ModifyBehavior(function(modify)
        modify.CustomIndexing = true
    end)
end

---@return FIN.UUID
function IPAddress:GetAddress()
    return self.m_address
end

---@param ipAddress SphinxOS.System.Net.IPAddress
function IPAddress:Equals(ipAddress)
    return self:GetAddress() == ipAddress:GetAddress()
end

---@private
function IPAddress:__newindex()
    --//TODO: add readonly option to classSystem creation
    error("SphinxOS.System.Net.IPAddress is read only.")
end

---@private
function IPAddress:__tostring()
    return self:GetAddress()
end

---@return string address
function IPAddress:Serialize()
    return self.m_address
end

return Utils.Class.Create(IPAddress, "SphinxOS.System.Net.IPAddress", require("//OS/System/Json/Serializable"))
