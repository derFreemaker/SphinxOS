---@class SphinxOS.System.Terminal.StreamAdapter : SphinxOS.System.IO.IStream
---@field m_terminal SphinxOS.System.Terminal
---@field m_buffer string
---
---@overload fun(terminal: SphinxOS.System.Terminal) : SphinxOS.System.Terminal.StreamAdapter
local StreamAdapter = {}

---@private
---@deprecated
---@param terminal SphinxOS.System.Terminal
function StreamAdapter:__init(terminal)
    self.m_terminal = terminal
end

function StreamAdapter:IsTTY()
    return true
end

function StreamAdapter:Close()
end

function StreamAdapter:Flush()
    self.m_terminal:Write(self.m_buffer)
end

function StreamAdapter:CanWrite()
    return true
end

---@param str string
function StreamAdapter:Write(str)
    self.m_buffer = self.m_buffer .. str
end

function StreamAdapter:CanRead()
    return false
end

StreamAdapter.ReadLength = Utils.Class.Placeholder
StreamAdapter.ReadAll = Utils.Class.Placeholder
StreamAdapter.ReadLineWithLineEnding = Utils.Class.Placeholder
StreamAdapter.ReadLineWithoutLineEnding = Utils.Class.Placeholder

function StreamAdapter:CanSeek()
    return false
end

StreamAdapter.GetPosition = Utils.Class.Placeholder
StreamAdapter.SetPosition = Utils.Class.Placeholder
StreamAdapter.SetFromCurrent = Utils.Class.Placeholder
StreamAdapter.SetFromEnd = Utils.Class.Placeholder

return Utils.Class.Create(StreamAdapter, "SphinxOS.System.Terminal.StreamAdapter",
    { BaseClass = require("//OS/System/IO/IStream") })
