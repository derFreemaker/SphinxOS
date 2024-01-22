local Environment = require("//OS/System/Threading/Environment")
local Process = require("//OS/System/Threading/Process")

---@class SphinxOS.System.Threading.Task : object
---@field m_func function
---
---@field m_thread thread
---@field m_closed boolean
---@field m_environment SphinxOS.System.Threading.Environment
---
---@field m_success boolean
---@field m_results any[]
---@field m_error string?
---@field m_traceback string?
---@overload fun(func: function) : SphinxOS.System.Threading.Task
local Task = {}

---@alias SphinxOS.System.Threading.Task.__init fun(func: function)

---@private
---@param func function
function Task:__init(func)
    self.m_func = func

    self.m_closed = false
    self.m_environment = Environment.Static__Current()

    self.m_success = true
    self.m_results = {}
end

---@private
function Task:__gc()
    self:Close()
end

---@return boolean
function Task:IsSuccess()
    return self.m_success
end

---@return any ... results
function Task:GetResults()
    return table.unpack(self.m_results)
end

---@return any[] results
function Task:GetResultsArray()
    return self.m_results
end

---@return string
function Task:GetTraceback()
    return self:Traceback()
end

---@return "not created" | "normal" | "running" | "suspended" | "dead"
function Task:State()
    if self.m_thread == nil then
        return "not created"
    end
    return coroutine.status(self.m_thread)
end

---@param success boolean
---@param ... any
---@return boolean, any[]
local function retrieveValues(success, ...)
    return success, { ... }
end
---@param ... any
---@return any ...
function Task:Execute(...)
    ---@param ... any
    local function invokeFunc(func, ...)
        return { func(...) }
    end

    self.m_thread = coroutine.create(invokeFunc)
    self.m_closed = false
    self.m_traceback = nil

    local currentEnv = Environment.Static__Current()

    self.m_environment:Prepare()
    currentEnv.inTask = true
    self.m_success, self.m_results = retrieveValues(coroutine.resume(self.m_thread, self.m_func, ...))
    currentEnv.inTask = false
    self.m_environment:Revert()

    Process.Static__Running():Check()

    if not self.m_success then
        self.m_error = self.m_results[1]
    end

    return table.unpack(self.m_results)
end

---@private
function Task:CheckThreadState()
    local state = self:State()

    if state == "not created" then
        error("cannot resume a not started task")
    end

    if self.m_closed then
        error("cannot resume a closed task")
    end

    if state == "running" then
        error("cannot resume running task")
    end

    if state == "dead" then
        error("cannot resume dead task")
    end
end

---@param ... any parameters
---@return any ... results
function Task:Resume(...)
    self:CheckThreadState()
    self.m_success, self.m_error = coroutine.resume(self.m_thread, ...)
    return table.unpack(self.m_results)
end

function Task:Close()
    if self.m_closed then
        return
    end
    if not self.m_success then
        self:Traceback()
    end
    coroutine.close(self.m_thread)
    self.m_closed = true
end

---@private
---@return string traceback
function Task:Traceback()
    if self.m_traceback ~= nil or self.m_closed then
        return self.m_traceback
    end
    self.m_traceback = debug.traceback(self.m_thread, self.m_error or "") .. "\n[TASK START]"
    return self.m_traceback
end

---@return string?
function Task:GetError()
    if not self.m_closed then
        return
    end

    if not self.m_success then
        return "Task [Error]:\n" .. self:Traceback()
    end
end

return Utils.Class.Create(Task, "SphinxOS.System.Threading.Task")
