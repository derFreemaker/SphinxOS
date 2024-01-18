---@class SphinxOS.System.IO.IStream : object
local IStream = {}

function IStream:Close()
    error("not implemented")
end

IStream.Close = Utils.Class.IsAbstract

function IStream:Flush()
    error("not implemented")
end

IStream.Flush = Utils.Class.IsAbstract

---@return boolean
function IStream:CanRead()
    error("not implemented")
end

IStream.CanRead = Utils.Class.IsAbstract

---@return boolean
function IStream:CanWrite()
    error("not implemented")
end

IStream.CanWrite = Utils.Class.IsAbstract

---@return boolean
function IStream:CanSeek()
    error("not implemented")
end

IStream.CanSeek = Utils.Class.IsAbstract

---@return integer
function IStream:Length()
    error("not implemented")
end

IStream.Length = Utils.Class.IsAbstract

---@param str string
function IStream:Write(str)
    error("not implemented")
end

IStream.Write = Utils.Class.IsAbstract

---@param str string
function IStream:WriteLine(str)
    self:Write(str .. "\n")
end

---@alias SphinxOS.System.IO.IStream.ReadMode
---|"a" all
---|"l" line without line ending
---|"L" line with line ending

---@protected
---@param length integer
---@return string
function IStream:ReadLength(length)
    error("not implemented")
end

IStream.ReadLength = Utils.Class.IsAbstract

---@protected
---@return string
function IStream:ReadAll()
    error("not implemented")
end

IStream.ReadAll = Utils.Class.IsAbstract

---@protected
---@return string
function IStream:ReadLineWithoutLineEnding()
    error("not implemented")
end

IStream.ReadLineWithoutLineEnding = Utils.Class.IsAbstract

---@protected
---@return string
function IStream:ReadLineWithLineEnding()
    error("not implemented")
end

IStream.ReadLineWithLineEnding = Utils.Class.IsAbstract

---@param modeOrLength SphinxOS.System.IO.IStream.ReadMode | integer
---@return string?
function IStream:Read(modeOrLength)
    if not self:CanRead() then
        error("unable to read in this stream")
    end

    if type(modeOrLength) == "number" then
        return self:ReadLength(modeOrLength)
    end

    if modeOrLength == "a" then
        return self:ReadAll()
    end

    if modeOrLength == "l" then
        return self:ReadLineWithoutLineEnding()
    end

    if modeOrLength == "L" then
        return self:ReadLineWithLineEnding()
    end

    return nil
end

---@protected
---@return integer
function IStream:GetPosition()
    error("not implemented")
end

IStream.GetPosition = Utils.Class.IsAbstract

---@protected
---@param pos integer
function IStream:SetPosition(pos)
    error("not implemented")
end

IStream.SetPosition = Utils.Class.IsAbstract

---@protected
---@param offset integer
function IStream:SetFromCurrent(offset)
    error("not implemented")
end

IStream.SetFromCurrent = Utils.Class.IsAbstract

---@protected
---@param offset integer
function IStream:SetFromEnd(offset)
    error("not implemented")
end

IStream.SetFromEnd = Utils.Class.IsAbstract

---@alias SphinxOS.System.IO.IStream.SeekMode
---|>"cur" from current position
---|"set" set position
---|"end" from end position

---@param mode (SphinxOS.System.IO.IStream.SeekMode | integer)?
---@param offset integer?
---@return integer pos current position
function IStream:Seek(mode, offset)
    if mode == nil and offset == nil then
        return self:GetPosition()
    end

    if not self:CanSeek() then
        error("unable to seek in this stream")
    end

    if type(mode) == "number" then
        offset = mode
        mode = "cur"
    end
    offset = offset or 0

    if mode == "cur" then
        self:SetFromCurrent(offset)
    elseif mode == "set" then
        self:SetPosition(offset)
    elseif mode == "end" then
        self:SetFromEnd(offset)
    end

    return self:GetPosition()
end

return Utils.Class.Create(IStream, "SphinxOS.System.IO.IStream", nil, { IsAbstract = true })
