local Buffer = require("//OS/System/IO/Buffer")
local Stream = require("//OS/System/IO/Stream")

local Environment = require("//OS/System/Threading/Environment")

---@type table<integer, SphinxOS.System.Threading.Process>
local _processes = {}

---@alias SphinxOS.System.Threading.Process.State
---|0 waiting
---|10 running
---|20 stop
---|30 kill
---|50 finished
---|100 dead

---@class SphinxOS.System.Threading.Process.Options
---@field parent (SphinxOS.System.Threading.Process | false)?
---@field environment SphinxOS.System.Threading.Environment.Options?
---
---@field stdIn SphinxOS.System.IO.IStream?
---@field stdOut SphinxOS.System.IO.IStream?
---@field stdErr SphinxOS.System.IO.IStream?

---@class SphinxOS.System.Threading.Process : object
---@field ID integer
---@field m_co thread
---
---@field m_state SphinxOS.System.Threading.Process.State
---@field m_environment SphinxOS.System.Threading.Environment
---
---@field m_parent SphinxOS.System.Threading.Process?
---@field m_childs SphinxOS.System.Threading.Process[]
---
---@field stdIn SphinxOS.System.IO.IStream
---@field stdOut SphinxOS.System.IO.IStream
---@field stdErr SphinxOS.System.IO.IStream
---
---@field m_success boolean?
---@field m_results any[]?
---@field m_error string?
---@field m_traceback string?
---@overload fun(func: function, options: SphinxOS.System.Threading.Process.Options?) : SphinxOS.System.Threading.Process
local Process = {}

---@alias SphinxOS.System.Threading.Process.__init fun(func: function, options: SphinxOS.System.Threading.Process.Options?)

---@private
---@param func function
---@param options SphinxOS.System.Threading.Process.Options?
function Process:__init(func, options)
    if not options then
        options = {}
    end

    self.ID = #_processes + 1
    self.m_state = 0

    self.m_childs = setmetatable({}, { __mode = 'v' })

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

        self.stdIn = options.stdIn or options.parent.stdIn
        self.stdOut = options.stdOut or options.parent.stdOut
        self.stdErr = options.stdErr or options.parent.stdErr

        if options.environment then
            self.m_environment = Environment(options.environment)
        else
            self.m_environment = options.parent.m_environment
        end

        table.insert(self.m_parent.m_childs, self)
    else
        if options.environment then
            self.m_environment = Environment(options.environment)
        else
            self.m_environment = Environment.Static__Default()
        end

        self.stdIn = options.stdIn or Stream(Buffer(), "rs")
        self.stdOut = options.stdOut or Stream(Buffer(), "rws")
        self.stdErr = options.stdErr or Stream(Buffer(), "w")
    end

    _processes[self.ID] = self
end

---@private
function Process:__gc()
    self:Kill()
end

function Process:Prepare()
    self.m_environment:Prepare()

    __ENV.Process = self
end

function Process:Cleanup()
    self.m_environment:Revert()

    if self.m_parent then
        self.m_parent:Prepare()
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

    self:Prepare()
    self.m_state = 10
    self.m_success, self.m_results = retrieveValues(coroutine.resume(self.m_co, ...))
    self:Cleanup()

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
    self.m_state = 20

    for _, process in pairs(self.m_childs) do
        process:Stop()
    end

    if self.m_environment.inTask then
        return coroutine.yield(...)
    end

    if self ~= Process.Static__Running() then
        error("can only stop currently running process")
    end

    return coroutine.yield(...)
end

function Process:Kill()
    if Process.Static__Running() == self then
        error("cannot kill running process")
    end

    for _, process in pairs(self.m_childs) do
        process:Kill()
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

function Process:Check()
    if self.m_state == 20 then
        self:Stop()
    elseif self.m_state == 30 then
        self:Kill()
    end
end

---@return SphinxOS.System.Threading.Process
function Process.Static__Running()
    return __ENV.Process
end

---@param id integer
---@return SphinxOS.System.Threading.Process?
function Process.Static__GetProcess(id)
    return _processes[id]
end

return Utils.Class.Create(Process, "SphinxOS.System.Threading.Process")
