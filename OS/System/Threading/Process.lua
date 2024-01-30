local Buffer = require("//OS/System/IO/Buffer")
local Stream = require("//OS/System/IO/Stream")
local Thread = require("//OS/System/Threading/Thread")

local Environment = require("//OS/System/Threading/Environment")

---@alias SphinxOS.System.Threading.PID
---|integer

---@alias SphinxOS.System.Threading.Process.Signal string
---|"SIGINT"

---@type table<SphinxOS.System.Threading.PID, SphinxOS.System.Threading.Process>
local _processes = {}

---@class SphinxOS.System.Threading.Process.Options
---@field parent (SphinxOS.System.Threading.Process | false)?
---@field environment SphinxOS.System.Threading.Environment.Options?
---
---@field stdIn SphinxOS.System.IO.IStream?
---@field stdOut SphinxOS.System.IO.IStream?
---@field stdErr SphinxOS.System.IO.IStream?

---@class SphinxOS.System.Threading.Process : object
---@field PID SphinxOS.System.Threading.PID
---@field m_thread SphinxOS.System.Threading.Thread
---
---@field m_closed boolean
---@field m_environment SphinxOS.System.Threading.Environment
---
---@field m_parent SphinxOS.System.Threading.PID?
---@field m_childs table<SphinxOS.System.Threading.PID, true>
---
---@field StdIn SphinxOS.System.IO.IStream
---@field StdOut SphinxOS.System.IO.IStream
---@field StdErr SphinxOS.System.IO.IStream
---
---@field Handlers table<SphinxOS.System.Threading.Process.Signal, fun()>
---
---@overload fun(func: function, options: SphinxOS.System.Threading.Process.Options?) : SphinxOS.System.Threading.Process
local Process = {}

---@alias SphinxOS.System.Threading.Process.__init fun(func: function, options: SphinxOS.System.Threading.Process.Options?)

---@return SphinxOS.System.Threading.PID
function Process.Static__GeneratePID()
    return #_processes + 1
end

---@private
---@param func function
---@param options SphinxOS.System.Threading.Process.Options?
function Process:__init(func, options)
    if not options then
        options = {}
    end

    self.PID = self.Static__GeneratePID()
    self.m_closed = false

    self.m_childs = setmetatable({}, { __mode = 'v' })

    self.m_thread = Thread(func)

    self.Handlers = {}
    self.Handlers["SIGINT"] = function()
        self:Kill()
    end

    if options.parent == nil then
        options.parent = Process.Static__Running()
    end

    if options.parent then
        self.m_parent = options.parent.PID
        self.m_childPos = options.parent:AddChild(self.PID)

        self.StdIn = options.stdIn or options.parent.StdIn
        self.StdOut = options.stdOut or options.parent.StdOut
        self.StdErr = options.stdErr or options.parent.StdErr

        if options.environment then
            self.m_environment = Environment(options.environment)
        else
            self.m_environment = options.parent.m_environment
        end
    else
        if options.environment then
            self.m_environment = Environment(options.environment)
        else
            self.m_environment = Environment.Static__Default()
        end

        self.StdIn = options.stdIn or Stream(Buffer(), "rs")
        self.StdOut = options.stdOut or Stream(Buffer(), "rws")
        self.StdErr = options.stdErr or Stream(Buffer(), "w")
    end

    _processes[self.PID] = self
end

---@private
function Process:__gc()
    self:Close()
end

---@return SphinxOS.System.Threading.Process?
function Process:GetParent()
    if not self.m_parent then
        return nil
    end

    return _processes[self.m_parent]
end

---@private
---@param childPID SphinxOS.System.Threading.PID
function Process:AddChild(childPID)
    self.m_childs[childPID] = true
end

---@private
---@param childPID SphinxOS.System.Threading.PID
function Process:RemoveChild(childPID)
    self.m_childs[childPID] = nil
end

--- is nil if process has not finished yet
---@return boolean?
function Process:IsSuccess()
    return self.m_thread:IsSuccess()
end

---@return string?
function Process:GetError()
    return self.m_thread:GetError()
end

---@param signal SphinxOS.System.Threading.Process.Signal
function Process:EmitSignal(signal)
    local handler = self.Handlers[signal]
    if handler then
        handler()
    end
end

function Process:Prepare()
    self.m_environment:Prepare()

    __ENV.Process = self
end

function Process:Cleanup()
    self.m_environment:Revert()

    if self.m_parent then
        _processes[self.m_parent]:Prepare()
    else
        __ENV.Process = nil
    end
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
    self:GetParent():RemoveChild(self.PID)
end

---@return string?
function Process:Traceback()
    if self.m_thread:IsSuccess() then
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

---@param id SphinxOS.System.Threading.PID
---@return SphinxOS.System.Threading.Process?
function Process.Static__GetProcess(id)
    return _processes[id]
end

return Utils.Class.Create(Process, "SphinxOS.System.Threading.Process")
