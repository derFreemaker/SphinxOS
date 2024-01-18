---@class SphinxOS.System.IO.IBuffer : object
local IBuffer = {}

---@return integer
function IBuffer:Length()
    error("not implemented")
end

---@param str string
function IBuffer:Write(str)
    error("not implemented")
end

---@param startPos integer?
---@param endPos integer?
---@return string
function IBuffer:Read(startPos, endPos)
    error("not implemented")
end

---@param startPos integer?
---@param withLineEnding boolean?
---@return string
function IBuffer:ReadLine(startPos, withLineEnding)
    error("not implemented")
end

return Utils.Class.Create(IBuffer, "SphinxOS.System.IO.IBuffer", nil, { IsAbstract = true })
