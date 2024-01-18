---@class SphinxOS.Adapter.ConsoleInStreamAdapter : SphinxOS.System.IO.IStream
local ConsoleInStreamAdapter = {}

function ConsoleInStreamAdapter:CanRead()
    return true
end

function ConsoleInStreamAdapter:CanWrite()
    return true
end

function ConsoleInStreamAdapter:CanSeek()
    return true
end

---@return integer
function ConsoleInStreamAdapter:Length()
    return io.stdout:read("a"):len()
end

function ConsoleInStreamAdapter:Flush()
    io.stdout:flush()
end

function ConsoleInStreamAdapter:Close()
end

---@param str string
function ConsoleInStreamAdapter:Write(str)
    io.stdout:write(str)
end

---@protected
---@param length integer
---@return string
function ConsoleInStreamAdapter:ReadLength(length)
    return io.stdout:read(length)
end

---@protected
---@return string
function ConsoleInStreamAdapter:ReadAll()
    return io.stdout:read("a")
end

---@protected
---@return string
function ConsoleInStreamAdapter:ReadLineWithoutLineEnding()
    return io.stdout:read("l")
end

---@protected
---@return string
function ConsoleInStreamAdapter:ReadLineWithLineEnding()
    return io.stdout:read("L")
end

---@protected
function ConsoleInStreamAdapter:GetPosition()
    return io.stdout:seek()
end

---@protected
---@param pos integer
function ConsoleInStreamAdapter:SetPosition(pos)
    io.stdout:seek("set", pos)
end

---@protected
---@param offset integer
function ConsoleInStreamAdapter:SetFromCurrent(offset)
    io.stdout:seek("cur", offset)
end

---@protected
---@param offset integer
function ConsoleInStreamAdapter:SetFromEnd(offset)
    io.stdout:seek("end", offset)
end

return Utils.Class.Create(ConsoleInStreamAdapter, "SphinxOS.Adapter.ConsoleInStreamAdapter",
    require("/OS/System/IO/IStream"))
