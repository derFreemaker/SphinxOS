---@class SphinxOS.System.Net.IPAddress : SphinxOS.System.Json.Serializable
---@field private m_address FIN.UUID
---@overload fun(address: string) : SphinxOS.System.Net.IPAddress
local IPAddress = {}

---@private
---@param address FIN.UUID
function IPAddress:__init(address)
    self.m_address = address
end

---@return FIN.UUID
function IPAddress:GetAddress()
    return self.m_address
end

---@param other SphinxOS.System.Net.IPAddress
function IPAddress:Equals(other)
    return self.m_address == other.m_address
end

---@private
function IPAddress:__tostring()
    return self:GetAddress()
end

---@return string address
function IPAddress:Serialize()
    return self.m_address
end

return Utils.Class.Create(IPAddress, "SphinxOS.System.Net.IPAddress", {
    BaseClass = require("//OS/System/Json/Serializable")
})
