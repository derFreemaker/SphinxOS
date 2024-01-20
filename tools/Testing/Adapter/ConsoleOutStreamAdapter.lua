---@class SphinxOS.Adapter.ConsoleInStreamAdapter : SphinxOS.System.IO.IStream
local ConsoleOutStreamAdapter = {}

function ConsoleOutStreamAdapter:CanRead()
    return true
end

function ConsoleOutStreamAdapter:CanWrite()
    return true
end

function ConsoleOutStreamAdapter:CanSeek()
    return true
end

---@return integer
function ConsoleOutStreamAdapter:Length()
    return io.stdout:read("a"):len()
end

function ConsoleOutStreamAdapter:Flush()
    io.stdout:flush()
end

function ConsoleOutStreamAdapter:Close()
end

---@param str string
function ConsoleOutStreamAdapter:Write(str)
    io.stdout:write(str)
end

---@protected
---@param length integer
---@return string
function ConsoleOutStreamAdapter:ReadLength(length)
    return io.stdout:read(length)
end

---@protected
---@return string
function ConsoleOutStreamAdapter:ReadAll()
    return io.stdout:read("a")
end

---@protected
---@return string
function ConsoleOutStreamAdapter:ReadLineWithoutLineEnding()
    return io.stdout:read("l")
end

---@protected
---@return string
function ConsoleOutStreamAdapter:ReadLineWithLineEnding()
    return io.stdout:read("L")
end

---@protected
function ConsoleOutStreamAdapter:GetPosition()
    return io.stdout:seek()
end

---@protected
---@param pos integer
function ConsoleOutStreamAdapter:SetPosition(pos)
    io.stdout:seek("set", pos)
end

---@protected
---@param offset integer
function ConsoleOutStreamAdapter:SetFromCurrent(offset)
    io.stdout:seek("cur", offset)
end

---@protected
---@param offset integer
function ConsoleOutStreamAdapter:SetFromEnd(offset)
    io.stdout:seek("end", offset)
end

return Utils.Class.Create(ConsoleOutStreamAdapter, "SphinxOS.Adapter.ConsoleOutStreamAdapter",
    require("/OS/System/IO/IStream"))
