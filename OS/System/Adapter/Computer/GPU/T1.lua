local PCIDeviceReference = require("//OS/System/References/PCIDeviceReference")

---@type SphinxOS.System.Data.Cache<SphinxOS.System.References.IReference<FIN.Components.GPU_T1_C>>
local Cache = require("//OS/System/Data/Cache")()

---@class SphinxOS.System.Adapter.Computer.GPU.T1 : SphinxOS.System.IAdapter
---@field m_ref SphinxOS.System.References.IReference<FIN.Components.GPU_T1_C>
local GPUT1 = {}

---@private
---@param index number
function GPUT1:__init(index)
    if not index then
        index = 1
    end

    local success, gpu = Cache:TryGet(index)
    if not success then
        gpu = PCIDeviceReference(classes.GPU_T1_C, index)
        if not gpu:Fetch() then
            error("gpu T1 not found")
        end
        Cache:Add(index, gpu)
    end

    self.m_ref = gpu
end

---@param screen FIN.Components.Screen
function GPUT1:BindScreen(screen)
    self.m_ref:Get():bindScreen(screen)
end

---@return FIN.Components.Screen
function GPUT1:GetScreen()
    return self.m_ref:Get():getScreen()
end

---@return FIN.Components.Vector2D
function GPUT1:GetScreenSize()
    return self.m_ref:Get():getScreenSize()
end

---@param width integer
---@param height integer
function GPUT1:SetSize(width, height)
    self.m_ref:Get():setSize(width, height)
end

---@return integer width, integer height
function GPUT1:GetSize()
    return self.m_ref:Get():getSize()
end

---@param buffer FIN.Components.GPUT1Buffer
function GPUT1:SetBuffer(buffer)
    self.m_ref:Get():setBuffer(buffer)
end

function GPUT1:Flush()
    self.m_ref:Get():flush()
end

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param str string
function GPUT1:Fill(x, y, width, height, str)
    self.m_ref:Get():fill(x, y, width, height, str)
end

---@param r float
---@param g float
---@param b float
---@param a float
function GPUT1:SetForeground(r, g, b, a)
    self.m_ref:Get():setForeground(r, g, b, a)
end

---@param r float
---@param g float
---@param b float
---@param a float
function GPUT1:SetBackground(r, g, b, a)
    self.m_ref:Get():setBackground(r, g, b, a)
end

---@param x integer
---@param y integer
---@param str string
function GPUT1:SetText(x, y, str)
    self.m_ref:Get():setText(x, y, str)
end

return Utils.Class.Create(GPUT1, "SphinxOS.System.Adapter.Computer.GPU.T1",
    { BaseClass = require("//OS/System/Adapter/IAdapter") })
