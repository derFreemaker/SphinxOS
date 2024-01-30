local Coroutine = require("//OS/System/Threading/Coroutine")

---@type table<integer, SphinxOS.System.Threading.Thread>
local _threadStack = {}
local _threadStop = {}

---@class SphinxOS.System.Threading.Thread : object
---@field m_position number?
---
---@field m_co thread
---
---@field m_success boolean
---@field m_error string?
---@field m_traceback string?
---@overload fun(func: function) : SphinxOS.System.Threading.Thread
local Thread = {}

---@private
---@deprecated
---@param func function
function Thread:__init(func)
    self.m_co = Coroutine.create(func)

    self.m_success = false
end

---@private
---@deprecated
function Thread:__gc()
    self:Close()
end

function Thread:IsSuccess()
    return self.m_success
end

---@return string
function Thread:GetError()
    return self.m_error
end

---@return boolean success, any[] results
function Thread:Execute(...)
    if Coroutine.status(self.m_co) ~= "suspended" then
        error("can not execute normal, dead or running coroutine")
    end

    local index = #_threadStack + 1
    self.m_position = index
    _threadStack[index] = self

    local results = { Coroutine.resume(self.m_co, ...) }

    ---@type boolean, any, any, any[]
    local val1, val2, params = (function(success, val1, val2, ...)
        self.m_success = success
        return val1, val2, { ... }
    end)(table.unpack(results))

    if self.m_success then
        if val1 == _threadStop then
            _threadStack[val2]:Kill(table.unpack(params))
        end
    end

    _threadStack[#_threadStack] = nil

    return self.m_success, { val1, val2, table.unpack(params) }
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
    local noError, errorObject = Coroutine.close(self.m_co)

    self.m_success = noError
    self.m_error = tostring(errorObject)

    return noError, errorObject
end

---@return
---| '"running"'   # Is running.
---| '"suspended"' # Is suspended or not started.
---| '"normal"'    # Is active but not running.
---| '"dead"'      # Has finished or stopped with an error.
---@nodiscard
function Thread:Status()
    return Coroutine.status(self.m_co)
end

---@return string?
function Thread:Traceback()
    if self.m_success then
        return nil
    end

    if self.m_traceback then
        return self.m_traceback
    end

    self.m_traceback = debug.traceback(self.m_co, self.m_error or "")
    return self.m_traceback
end

return Utils.Class.Create(Thread, "SphinxOS.System.Threading.Thread")
