---@class SphinxOS.System.IO.Buffer : SphinxOS.System.IO.IBuffer
---@field m_buffer string
---@field m_length integer
---@overload fun(str: string?) : SphinxOS.System.IO.Buffer
local Buffer = {}

---@alias SphinxOS.System.IO.Buffer.__init fun(str: string?)

---@private
---@param str string?
function Buffer:__init(str)
    self.m_buffer = str or ""
    self.m_length = self.m_buffer:len()
end

---@return integer
function Buffer:Length()
    return self.m_length
end

---@param str string
function Buffer:Write(str)
    self.m_length = self.m_length + str:len()
    self.m_buffer = self.m_buffer .. str
end

---@param startPos integer?
---@param endPos integer?
---@return string
function Buffer:Read(startPos, endPos)
    return self.m_buffer:sub(startPos or 0, endPos)
end

---@param startPos integer?
---@param withLineEnding boolean?
---@return string
function Buffer:ReadLine(startPos, withLineEnding)
    startPos = startPos or 1
    withLineEnding = withLineEnding or false

    local eol = self.m_buffer:find("\n", startPos)
    return self.m_buffer:sub(startPos, eol)
end

return Utils.Class.Create(Buffer, "SphinxOS.System.IO.Buffer", require("//OS/System/IO/IBuffer"))
