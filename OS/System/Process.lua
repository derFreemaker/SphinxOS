local Buffer = require("//OS/System/IO/Buffer")
local Stream = require("//OS/System/IO/Stream")
local Require = require("//OS/System/Require")

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
---@field m_workingDirectory string
---
---@overload fun(func: function, options: SphinxOS.System.Process.Options?) : SphinxOS.System.Process
local Process = {}

---@alias SphinxOS.System.Process.__init fun(func: function, options: SphinxOS.System.Process.Options?)

---@class SphinxOS.System.Process.Options
---@field parent (SphinxOS.System.Process | false)?
---@field workingDirectory string?
---
---@field stdIn SphinxOS.System.IO.IStream?
---@field stdOut SphinxOS.System.IO.IStream?
---@field stdErr SphinxOS.System.IO.IStream?

---@private
---@param func function
---@param options SphinxOS.System.Process.Options?
function Process:__init(func, options)
    if not options then
        options = {}
    end

    self.ID = #_process.processes + 1
    self.m_state = 0

    self.m_co = coroutine.create(
        function(...)
            local result = { func(...) }
            self.m_state = 50
            return table.unpack(result)
        end
    )

    if options.parent == nil then
        options.parent = Process.Static__Running()
    end

    if options.parent then
        self.m_parent = options.parent

        self.m_environment = Utils.Table.Copy(options.parent.m_environment)

        self.stdIn = options.stdIn or options.parent.stdIn
        self.stdOut = options.stdOut or options.parent.stdOut
        self.stdErr = options.stdErr or options.parent.stdErr

        self.m_workingDirectory = options.workingDirectory or options.parent.m_workingDirectory
    else
        self.m_environment = {} --//TODO: get default environment

        self.stdIn = options.stdIn or Stream(Buffer(), "rs")
        self.stdOut = options.stdOut or Stream(Buffer(), "rws")
        self.stdErr = options.stdErr or Stream(Buffer(), "w")

        self.m_workingDirectory = options.workingDirectory or "/"
    end

    _process.coToPID[self.m_co] = self.ID
    _process.processes[self.ID] = self
end

---@private
function Process:m_prepare()
    __ENV = {}
    __ENV.ENV = self.m_environment
    __ENV.Process = self

    Require.SetWorkingDirectory(self.m_workingDirectory)
end

---@private
function Process:m_cleanup()
    if self.m_parent then
        self.m_parent:m_prepare()
    else
        __ENV.Process = nil
        Require.SetWorkingDirectory()
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
