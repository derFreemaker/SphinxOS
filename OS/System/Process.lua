local Buffer = require("/OS/System/IO/Buffer")
local Stream = require("/OS/System/IO/Stream")

local _process = {
    ---@type table<thread, integer>
    coToPID = {},
    ---@type table<integer, SphinxOS.System.Process>
    processes = {}
}

---@alias SphinxOS.System.Process.State
---|0 waiting
---|10 running
---|50 finished
---|100 dead

---@class SphinxOS.System.Process : object
---@field ID integer
---@field m_co thread
---
---@field m_environment table<string, string>
---@field m_parent SphinxOS.System.Process?
---@field m_state SphinxOS.System.Process.State
---
---@field stdIn SphinxOS.System.IO.IStream
---@field stdOut SphinxOS.System.IO.IStream
---@field stdErr SphinxOS.System.IO.IStream
---
---@field m_success boolean?
---@field m_results any[]?
---@field m_error string?
---@field m_traceback string?
---
---@overload fun(func: function, parent: (SphinxOS.System.Process | false)?, options: SphinxOS.System.Process.Options?) : SphinxOS.System.Process
local Process = {}

---@alias SphinxOS.System.Process.__init fun(func: function, parent: (SphinxOS.System.Process | false)?, options: SphinxOS.System.Process.Options?)

---@class SphinxOS.System.Process.Options
---@field stdIn SphinxOS.System.IO.IStream?
---@field stdOut SphinxOS.System.IO.IStream?
---@field stdErr SphinxOS.System.IO.IStream?

---@private
---@param func function
---@param parent (SphinxOS.System.Process | false)?
---@param options SphinxOS.System.Process.Options?
function Process:__init(func, parent, options)
    if parent == nil then
        parent = Process.Static__Running()
    end
    if not options then
        options = {}
    end

    self.ID = #_process.processes + 1

    self.m_co = coroutine.create(
        function(...)
            local result = { func(...) }
            self.m_state = 50
            return table.unpack(result)
        end
    )

    if parent then
        self.m_parent = parent

        self.m_environment = Utils.Table.Copy(parent.m_environment)

        options.stdIn = options.stdIn or parent.stdIn
        options.stdOut = options.stdOut or parent.stdOut
        options.stdErr = options.stdErr or parent.stdErr
    else
        self.m_environment = {} --//TODO: get default environment

        --//TODO: replace default streams with actual streams
        options.stdIn = options.stdIn or Stream(Buffer(), "rs")
        options.stdOut = options.stdOut or Stream(Buffer(), "rws")
        options.stdErr = options.stdErr or Stream(Buffer(), "w")
    end

    self.m_state = 0

    self.stdIn = options.stdIn
    self.stdOut = options.stdOut
    self.stdErr = options.stdErr

    _process.coToPID[self.m_co] = self.ID
    _process.processes[self.ID] = self
end

---@private
function Process:m_prepare()
    __ENV = {}
    __ENV.ENV = self.m_environment
    __ENV.Process = self
end

---@private
function Process:m_cleanup()
    if self.m_parent then
        self.m_parent:m_prepare()
    else
        __ENV.Process = nil
    end
end

---@return any ...
function Process:GetResults()
    return table.unpack(self.m_results or {})
end

---@return any[] results
function Process:GetResultsArray()
    return self.m_results or {}
end

--- is nil if process has not finished yet
---@return boolean?
function Process:IsSuccess()
    return self.m_success
end

---@return string?
function Process:GetError()
    return self.m_error
end

---@return boolean, any ...
local function retrieveValues(success, ...)
    return success, { ... }
end
---@async
---@param ... any
---@return any ...
function Process:Execute(...)
    if self.m_state ~= 0 then
        error("cannot execute dead, finished or running process")
    end

    self:m_prepare()
    self.m_state = 10
    self.m_success, self.m_results = retrieveValues(coroutine.resume(self.m_co, ...))
    self:m_cleanup()

    if self.m_state == 10 then
        self.m_state = 0
    elseif self.m_state == 50 then
        self:Kill()
    end

    if not self.m_success then
        self.m_error = self.m_results[1]
        self:Traceback()
        self:Kill()
        return self:Traceback()
    end

    return table.unpack(self.m_results)
end

---@param ... any
---@return any ...
function Process:Stop(...)
    if self ~= Process.Static__Running() then
        error("can only stop currently running process")
    end

    return coroutine.yield(...)
end

function Process:Kill()
    if Process.Static__Running() == self then
        error("cannot kill running process")
    end

    self.m_state = 100
    coroutine.close(self.m_co)
end

---@return string
function Process:Traceback()
    if self.m_traceback then
        return self.m_traceback
    end

    self.m_traceback = debug.traceback(self.m_co, self.m_error)
    return self.m_traceback
end

---@return SphinxOS.System.Process
function Process.Static__Running()
    return __ENV.Process
end

---@param id integer
---@return SphinxOS.System.Process?
function Process.Static__GetProcess(id)
    return _process.processes[id]
end

return Utils.Class.Create(Process, "SphinxOS.Core.Process")
