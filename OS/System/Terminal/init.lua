local Process = require("//OS/System/Threading/Process")

---@class SphinxOS.System.Terminal : object
---@field Process SphinxOS.System.Threading.Process
---
---@field CurrentLine string
---@field m_buffer string[][]
---
---@field cursorPosX integer
---@field cursorPosY integer
---@field cursorVisible boolean
---
---@field Foreground Satisfactory.Components.Color
---@field Background Satisfactory.Components.Color
---
---@field LastScreenWidth integer
---@field LastScreenHeight integer
---@overload fun(process: SphinxOS.System.Threading.Process?, gpu: FIN.Components.GPU_T1_C) : SphinxOS.System.Terminal
local Terminal = {}

---@private
---@deprecated
---@param gpu FIN.Components.GPU_T1_C
---@param process SphinxOS.System.Threading.Process?
function Terminal:__init(gpu, process)
    self.Process = process or Process.Static__Running()

    self.m_gpu = gpu
    self.m_gpuBuffer = structs.GPUT1Buffer()
    gpu:setBuffer(self.m_gpuBuffer)

    self.m_buffer = {}

    self.cursorPosX = 1
    self.cursorPosY = 2
    self.cursorVisible = true

    self.Foreground = structs.Color({ 1, 1, 1, 1 })
    self.Background = structs.Color({ 0, 0, 0, 0 })
end

---@param str string
function Terminal:Write(str)
    local lines = Utils.String.Split(str, "\n")
    for _, line in pairs(lines) do
        local lineParts = self.m_buffer[self.CurrentLine]
        table.insert(lineParts, line)
        self.CurrentLine = self.CurrentLine + 1
    end
end

---@param buffer FIN.Components.GPUT1Buffer
function Terminal:Paint(buffer)
    local w, h = buffer:getSize()

    buffer:fill(0, 0, w, h, " ", nil, self.Background)

    local y = h - math.max(0, h - #self.m_buffer)
    while y > 0 do
        local line = self.m_buffer[y]

        --//TODO: handle escaped characters
        buffer:setText(0, y, Utils.String.Join(line, ""), { 1, 1, 1, 1 }, nil)

        y = y - 1
    end
end

return Utils.Class.Create(Terminal, "SphinxOS.System.Terminal")
