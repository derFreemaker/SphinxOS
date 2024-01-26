local ProxyReference = require("Core.References.ProxyReference")
local PCIDeviceReference = require("Core.References.PCIDeviceReference")

---@type SphinxOS.System.Data.Cache<SphinxOS.System.References.IReference<FIN.Components.NetworkCard_C>>
local Cache = require("//OS/System/Data/Cache")()

---@class SphinxOS.System.Adapter.Computer.NetworkCard : SphinxOS.System.IAdapter
---@field private m_ref SphinxOS.System.References.IReference<FIN.Components.NetworkCard_C>
---@field private m_openPorts table<integer, true>
---@overload fun(idOrIndexOrNetworkCard: (FIN.UUID | integer)?) : SphinxOS.System.Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndex (FIN.UUID | integer)?
function NetworkCard:__init(idOrIndex)
    self.m_openPorts = {}
    if not idOrIndex then
        idOrIndex = 1
    end

    local success, networkCard = Cache:TryGet(idOrIndex)
    if not success then
        if type(idOrIndex) == 'string' then
            ---@cast idOrIndex FIN.UUID
            networkCard = ProxyReference(idOrIndex)
        else
            ---@cast idOrIndex integer
            networkCard = PCIDeviceReference(classes.NetworkCard_C, idOrIndex)
        end
        if not networkCard:Fetch() then
            error("no network card found")
        end
        Cache:Add(idOrIndex, self)
    end

    self.m_ref = networkCard
    self:CloseAllPorts()
end

---@return FIN.UUID
function NetworkCard:GetIPAddress()
    return self.m_ref:Get().id
end

---@return string nick
function NetworkCard:GetNick()
    return self.m_ref:Get().nick
end

function NetworkCard:Listen()
    event.listen(self.m_ref)
end

---@param port integer
---@return boolean openedPort
function NetworkCard:OpenPort(port)
    if self.m_openPorts[port] then
        return false
    end

    self.m_ref:Get():open(port)
    self.m_openPorts[port] = true
    return true
end

---@param port integer
function NetworkCard:ClosePort(port)
    self.m_openPorts[port] = nil

    self.m_ref:Get():close(port)
end

function NetworkCard:CloseAllPorts()
    self.m_openPorts = {}

    self.m_ref:Get():closeAll()
end

---@param address FIN.UUID
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
    self.m_ref:Get():send(address, port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
    self.m_ref:Get():broadcast(port, ...)
end

return Utils.Class.Create(NetworkCard, 'SphinxOS.System.Adapter.Computer.NetworkCard',
    { BaseClass = require("//OS/System/Adapter/IAdapter") })
