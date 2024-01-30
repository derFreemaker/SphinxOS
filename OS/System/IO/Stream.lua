---@class SphinxOS.System.IO.Stream : SphinxOS.System.IO.IStream
---@field m_buffer SphinxOS.System.IO.IBuffer
---@field m_cache string
---@field m_position integer
---@field m_canRead boolean
---@field m_canWrite boolean
---@field m_canSeek boolean
---@overload fun(buffer: SphinxOS.System.IO.IBuffer, mode: SphinxOS.System.IO.Stream.Mode?) : SphinxOS.System.IO.Stream
local Stream = {}

---@alias SphinxOS.System.IO.Stream.__init fun(buffer: SphinxOS.System.IO.IBuffer, mode: SphinxOS.System.IO.Stream.Mode?)

---@alias SphinxOS.System.IO.Stream.Mode
---|"r" read
---|"w" write
---|"s" seek
---|"rw" read & write
---|"rs" read & seek
---|"ws" write & seek
---|>"rws" read & write & seek

---@private
---@param buffer SphinxOS.System.IO.IBuffer
---@param mode SphinxOS.System.IO.Stream.Mode?
function Stream:__init(buffer, mode)
    self.m_buffer = buffer
    self.m_cache = ""
    self.m_position = 0

    if not mode then
        self.m_canRead = true
        self.m_canWrite = true
        self.m_canSeek = true

        return
    end

    if mode:find("r", nil, true) then
        self.m_canRead = true
    else
        self.m_canRead = false
    end
    if mode:find("w", nil, true) then
        self.m_canWrite = true
    else
        self.m_canWrite = false
    end
    if mode:find("s", nil, true) then
        self.m_canSeek = true
    else
        self.m_canSeek = false
    end
end

---@private
function Stream:__gc()
    self:Close()
end

function Stream:Close()
    self:Flush()
end

function Stream:Flush()
    self.m_buffer:Write(self.m_cache)
end

function Stream:CanRead()
    return self.m_canRead
end

function Stream:CanWrite()
    return self.m_canWrite
end

function Stream:CanSeek()
    return self.m_canSeek
end

---@return integer
function Stream:GetPosition()
    return self.m_position
end

---@param str string
function Stream:Write(str)
    if not self.m_canWrite then
        error("unable to write in this stream")
    end

    self.m_buffer:Write(str)
    self.m_position = self.m_position + str:len()
end

---@protected
---@param length integer
---@return string
function Stream:ReadLength(length)
    local str = self.m_buffer:Read(self.m_position, self.m_position + length)
    self.m_position = self.m_position + length
    return str
end

---@protected
---@return string
function Stream:ReadAll()
    return self.m_buffer:Read()
end

---@protected
---@return string
function Stream:ReadLineWithoutLineEnding()
    return self.m_buffer:ReadLine(self.m_position, false)
end

---@protected
---@return string
function Stream:ReadLineWithLineEnding()
    return self.m_buffer:ReadLine(self.m_position, true)
end

---@protected
---@param pos integer
function Stream:SetPosition(pos)
    self.m_position = pos
end

---@protected
---@param offset integer
function Stream:SetFromCurrent(offset)
    self.m_position = self.m_position + offset
end

---@protected
---@param offset integer
function Stream:SetFromEnd(offset)
    self.m_position = self.m_position + offset
end

return Utils.Class.Create(Stream, "SphinxOS.System.IO.Stream", {
    BaseClass = require("//OS/System/IO/IStream")
})
