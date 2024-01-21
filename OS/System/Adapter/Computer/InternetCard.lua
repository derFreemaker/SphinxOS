local PCIDeviceReference = require("//OS/System/References/PCIDeviceReference")

---@type SphinxOS.System.Data.Cache<SphinxOS.System.References.IReference<FIN.Components.InternetCard_C>>
local Cache = require("//OS/System/Data/Cache")()

---@class SphinxOS.System.Adapter.Computer.InternetCard : object
---@field m_refInternetCard SphinxOS.System.References.IReference<FIN.Components.InternetCard_C>
local InternetCard = {}

---@param index number
function InternetCard:__init(index)
    if not index then
        index = 1
    end

    local success, internetCard = Cache:TryGet(index)
    if not success then
        internetCard = PCIDeviceReference(classes.InternetCard_C, index)
        if not internetCard:Fetch() then
            error("no internet card found")
        end
        Cache:Add(index, internetCard)
    end

    self.m_refInternetCard = internetCard
end

---@param url string
---@return boolean success, string? data, number statusCode
function InternetCard:Download(url)
    local req = self.m_refInternetCard:Get():request(url, 'GET', '')
    repeat until req:canGet()

    local code, data = req:get()

    if code > 302 then
        return false, data, code
    end

    return true, data, code
end

return Utils.Class.Create(InternetCard, "SphinxOS.System.Adapter.Computer.InternetCard")
