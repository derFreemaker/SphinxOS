local Thread = require("//OS/System/Threading/Thread")
local Environment = require("//OS/System/Threading/Environment")

---@class SphinxOS.System.Threading.Task : object
---@field m_func function
---
---@field m_thread SphinxOS.System.Threading.Thread
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
    return self.m_thread:Status()
end

---@param ... any
---@return any ...
function Task:Execute(...)
    self.m_thread = Thread(self.m_func)
    self.m_closed = false
    self.m_traceback = nil

    self.m_environment:Prepare()
    self.m_success, self.m_results = self.m_thread:Execute(...)
    self.m_environment:Revert()

    if not self.m_success then
        self.m_error = self.m_results[1]
    end

    return table.unpack(self.m_results)
end

---@param ... any
function Task:Kill(...)
    self.m_thread:Kill(...)
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

function Task:Close()
    if self.m_closed then
        return
    end

    if not self.m_success then
        self:Traceback()
    end

    self.m_thread:Close()
    self.m_closed = true
end

---@private
---@return string traceback
function Task:Traceback()
    if self.m_traceback ~= nil or self.m_closed then
        return self.m_traceback
    end

    self.m_traceback = self.m_thread:Traceback() .. "\n[TASK START]"
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
