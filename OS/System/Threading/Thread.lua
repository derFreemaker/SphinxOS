local Coroutine = require("//OS/System/Threading/Coroutine")

---@type table<integer, SphinxOS.System.Threading.Thread>
local _threadStack = {}
local _threadStop = {}

---@class SphinxOS.System.Threading.Thread : object
---@field co thread
---@field m_position number?
---@overload fun(func: function) : SphinxOS.System.Threading.Thread
local Thread = {}

---@private
---@param func function
function Thread:__init(func)
    self.co = Coroutine.create(func)
end

---@private
function Thread:__gc()
    self:Close()
end

---@return boolean success, any[] results
function Thread:Execute(...)
    if Coroutine.status(self.co) ~= "suspended" then
        error("can not execute normal, dead or running coroutine")
    end

    local index = #_threadStack + 1
    self.m_position = index
    _threadStack[index] = self

    local results = { Coroutine.resume(self.co, ...) }

    ---@type boolean, any, any, any[]
    local success, val1, val2, params = (function(success, val1, val2, ...)
        return success, val1, val2, { ... }
    end)(table.unpack(results))

    if success then
        if val1 == _threadStop then
            _threadStack[val2]:Kill(table.unpack(params))
        end
    end

    _threadStack[#_threadStack] = nil

    return success, { val1, val2, table.unpack(params) }
end

---@param ... any
function Thread:Kill(...)
    local threadStackLength = #_threadStack
    if threadStackLength > self.m_position then
        _threadStack[threadStackLength]:Kill(_threadStop, self.m_position, ...)
    end

    if _threadStack[#_threadStack] ~= self then
        error("unable to stop not running thread")
    end

    _threadStack[#_threadStack] = nil
    self.m_position = nil

    Coroutine.yield(...)
end

---@return boolean noError, any errorObject
function Thread:Close()
    return Coroutine.close(self.co)
end

return Utils.Class.Create(Thread, "SphinxOS.System.Threading.Thread")
