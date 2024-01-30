---@class SphinxOS.System.Terminal.LinePart
---@field X integer
---@field Text string
---@field Foreground Satisfactory.Components.Color
---@field Background Satisfactory.Components.Color

---@class SphinxOS.System.Terminal.Line : object
---@field Parts SphinxOS.System.Terminal.LinePart[]
local Line = {}

---@param buffer FIN.Components.GPUT1Buffer
---@param y integer
function Line:Paint(buffer, y)
    for _, linePart in pairs(self.Parts) do
        buffer:setText(linePart.X, y, linePart.Text, linePart.Foreground, linePart.Background)
    end
end

return Utils.Class.Create(Line, "SphinxOS.System.Terminal.Line")
