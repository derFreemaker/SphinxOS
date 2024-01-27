local Buffer = require("//OS/System/IO/Buffer")
local Stream = require("//OS/System/IO/Stream")
local Thread = require("//OS/System/Threading/Thread")

local Environment = require("//OS/System/Threading/Environment")

---@type table<integer, SphinxOS.System.Threading.Process>
local _processes = {}

---@class SphinxOS.System.Threading.Process.Options
---@field parent (SphinxOS.System.Threading.Process | false)?
---@field environment SphinxOS.System.Threading.Environment.Options?
---
---@field stdIn SphinxOS.System.IO.IStream?
---@field stdOut SphinxOS.System.IO.IStream?
---@field stdErr SphinxOS.System.IO.IStream?

---@class SphinxOS.System.Threading.Process : object
---@field ID integer
---@field m_thread SphinxOS.System.Threading.Thread
---
---@field m_closed boolean
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
    self.m_closed = false

    self.m_childs = setmetatable({}, { __mode = 'v' })

    self.m_thread = Thread(func)

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
    self:Close()
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

---@async
---@param ... any
---@return any ...
function Process:Execute(...)
    if self.m_closed then
        error("cannot not closed process")
    end

    self:Prepare()
    self.m_success, self.m_results = self.m_thread:Execute(...)
    self:Cleanup()

    self:Close()

    if not self.m_success then
        return self:Traceback()
    end

    return table.unpack(self.m_results)
end

---@param ... any
---@return any ...
function Process:Kill(...)
    self.m_thread:Kill(...)
end

function Process:Close()
    if self.m_closed then
        error("unable to close process that is not dead")
    end

    self:Traceback()
    self.m_closed = true

    self.m_success, self.m_error = self.m_thread:Close()
end

---@return string?
function Process:Traceback()
    if self.m_success then
        return nil
    end

    if self.m_traceback then
        return self.m_traceback
    end

    self.m_traceback = self.m_thread:Traceback() .. "\n[PROCESS START]"
    return self.m_traceback
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
