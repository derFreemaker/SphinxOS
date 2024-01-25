local Require = require("//OS/System/Require")

---@class SphinxOS.System.Threading.Environment.Global
---@field ENV SphinxOS.System.Threading.Environment
---@field Process SphinxOS.System.Threading.Process
__ENV = {}

---@type SphinxOS.System.Threading.Environment[]
local _history = {}

---@class SphinxOS.System.Threading.Environment.Options
---@field variables table<string, string>?
---@field workingDirectory string?

---@class SphinxOS.System.Threading.Environment : object
---@field variables table<string, string>
---@field workingDirectory string
---@overload fun(options: SphinxOS.System.Threading.Environment.Options?) : SphinxOS.System.Threading.Environment
local Environment = {}


---@return SphinxOS.System.Threading.Environment
function Environment.Static__Default()
    return Environment()
end

---@alias SphinxOS.System.Threading.Environment.__init fun(options: SphinxOS.System.Threading.Environment.Options?)

---@private
---@param options SphinxOS.System.Threading.Environment.Options?
function Environment:__init(options)
    if not options then
        options = {}
    end

    self.variables = options.variables or {}
    self.workingDirectory = options.workingDirectory or "/"
end

function Environment:Prepare()
    _history[#_history + 1] = self

    __ENV.ENV = self
    Require.SetWorkingDirectory(self.workingDirectory)
end

function Environment:Revert()
    __ENV.ENV = nil
    Require.SetWorkingDirectory()
    self.m_prepared = false

    _history[#_history] = nil
    local oldEnv = _history[#_history]
    if oldEnv then
        oldEnv:Prepare()
    end
end

---@return SphinxOS.System.Threading.Environment
function Environment.Static__Current()
    return __ENV.ENV
end

return Utils.Class.Create(Environment, "SphinxOS.System.Threading.Environment")
