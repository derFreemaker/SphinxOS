local PCIDeviceReference = require("//OS/System/References/PCIDeviceReference")

---@type SphinxOS.System.Data.Cache<SphinxOS.System.References.IReference<FIN.Components.GPU_T2_C>>
local Cache = require("//OS/System/Data/Cache")()

---@class SphinxOS.System.Adapter.Computer.GPU.T2 : SphinxOS.System.IAdapter
---@field m_ref SphinxOS.System.References.IReference<FIN.Components.GPU_T2_C>
local GPUT2 = {}

---@private
---@param index number
function GPUT2:__init(index)
    if not index then
        index = 1
    end

    local success, gpu = Cache:TryGet(index)
    if not success then
        gpu = PCIDeviceReference(classes.GPU_T2_C, index)
        if not gpu:Fetch() then
            error("gpu T2 not found")
        end
        Cache:Add(index, gpu)
    end

    self.m_ref = gpu
end

return Utils.Class.Create(GPUT2, "SphinxOS.System.Adapter.Computer.GPU.T2",
    { BaseClass = require("//OS/System/Adapter/IAdapter") })
