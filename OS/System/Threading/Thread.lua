---@type table<integer, SphinxOS.System.Threading.Thread>
local _threadStack = {}
local _threadStop = {}

---@class SphinxOS.System.Threading.Thread : object
---@field Coroutine thread
---@field m_position number?
---@overload fun(co: thread) : SphinxOS.System.Threading.Thread
local Thread = {}

---@private
---@param co thread
function Thread:__init(co)
    self.Coroutine = co
end

---@return boolean success, any ...
function Thread:Execute(...)
    local index = #_threadStack + 1
    self.m_position = index
    _threadStack[index] = self

    local results = { coroutine.resume(self.Coroutine, ...) }

    ---@type boolean, any, any, any[]
    local success, val1, val2, params = (function(success, val1, val2, ...)
        return success, val1, val2, { ... }
    end)(table.unpack(results))

    if success then
        if results[2] == _threadStop then
            _threadStack[results[3]]:Stop(params)
        end
    end

    _threadStack[#_threadStack] = nil

    return success, val1, val2, table.unpack(params)
end

---@param ... any
function Thread:Stop(...)
    local threadStackLength = #_threadStack
    if threadStackLength > self.m_position then
        _threadStack[threadStackLength]:Stop(_threadStop, self.m_position, ...)
    end

    if _threadStack[#_threadStack] ~= self then
        error("unable to stop not running thread")
    end

    _threadStack[#_threadStack] = nil
    self.m_position = nil

    return coroutine.yield(...)
end

return Utils.Class.Create(Thread, "SphinxOS.System.Threading.Thread")
