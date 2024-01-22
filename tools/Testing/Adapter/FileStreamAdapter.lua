---@class Testing.Adapter.FileStreamAdapter : SphinxOS.System.IO.IStream
---@field m_stream file*
---@field canRead boolean?
---@field canWrite boolean?
---@field canSeek boolean?
---@overload fun(stream: file*, options: Testing.Adapter.FileStreamAdapter.Options?) : Testing.Adapter.FileStreamAdapter
local FileStreamAdapter = {}

---@class Testing.Adapter.FileStreamAdapter.Options
---@field canRead boolean?
---@field canWrite boolean?
---@field canSeek boolean?

---@private
---@param stream file*
---@param options Testing.Adapter.FileStreamAdapter.Options?
function FileStreamAdapter:__init(stream, options)
    self.m_stream = stream

    options = options or {}
    self.m_canRead = options.canRead or false
    self.m_canWrite = options.canWrite or false
    self.m_canSeek = options.canSeek or false
end

function FileStreamAdapter:CanRead()
    return self.m_canRead
end

function FileStreamAdapter:CanWrite()
    return self.m_canWrite
end

function FileStreamAdapter:CanSeek()
    return self.m_canSeek
end

---@return integer
function FileStreamAdapter:Length()
    return self.m_stream:read("a"):len()
end

function FileStreamAdapter:Flush()
    self.m_stream:flush()
end

function FileStreamAdapter:Close()
end

---@param str string
function FileStreamAdapter:Write(str)
    self.m_stream:write(str)
end

---@protected
---@param length integer
---@return string
function FileStreamAdapter:ReadLength(length)
    return self.m_stream:read(length)
end

---@protected
---@return string
function FileStreamAdapter:ReadAll()
    return self.m_stream:read("a")
end

---@protected
---@return string
function FileStreamAdapter:ReadLineWithoutLineEnding()
    return self.m_stream:read("l")
end

---@protected
---@return string
function FileStreamAdapter:ReadLineWithLineEnding()
    return self.m_stream:read("L")
end

---@protected
function FileStreamAdapter:GetPosition()
    return self.m_stream:seek()
end

---@protected
---@param pos integer
function FileStreamAdapter:SetPosition(pos)
    self.m_stream:seek("set", pos)
end

---@protected
---@param offset integer
function FileStreamAdapter:SetFromCurrent(offset)
    self.m_stream:seek("cur", offset)
end

---@protected
---@param offset integer
function FileStreamAdapter:SetFromEnd(offset)
    self.m_stream:seek("end", offset)
end

return Utils.Class.Create(FileStreamAdapter, "Testing.Adapter.FileStreamAdapter",
    { BaseClass = require("/OS/System/IO/IStream") })
