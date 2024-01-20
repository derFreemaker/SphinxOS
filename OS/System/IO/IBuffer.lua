---@class SphinxOS.System.IO.IBuffer : object
local IStringBuffer = {}

---@return integer
function IStringBuffer:Length()
    error("not implemented")
end

---@param str string
function IStringBuffer:Write(str)
    error("not implemented")
end

---@param startPos integer?
---@param endPos integer?
---@return string
function IStringBuffer:Read(startPos, endPos)
    error("not implemented")
end

---@param startPos integer?
---@param withLineEnding boolean?
---@return string
function IStringBuffer:ReadLine(startPos, withLineEnding)
    error("not implemented")
end

return Utils.Class.Create(IStringBuffer, "SphinxOS.System.IO.IBuffer", nil, { IsAbstract = true })
