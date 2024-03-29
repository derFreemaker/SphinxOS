---@class SphinxOS.System.References.PCIDeviceReference<T> : SphinxOS.System.References.IReference<T>
---@field m_class FIN.PCIDevice
---@field m_index integer
---@overload fun(class: FIN.Class, index: integer) : SphinxOS.System.References.PCIDeviceReference
local PCIDeviceReference = {}

---@private
---@param class FIN.PCIDevice
---@param index integer
function PCIDeviceReference:__init(class, index)
    self.m_class = class
    self.m_index = index
end

---@protected
---@return FIN.PCIDevice
function PCIDeviceReference:InternalFetch()
    return computer.getPCIDevices(self.m_class)[self.m_index]
end

return Utils.Class.Create(PCIDeviceReference, "SphinxOS.System.References.PCIDeviceReference", {
    BaseClass = require("//OS/System/References/IReference")
})
