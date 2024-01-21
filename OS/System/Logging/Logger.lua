local Event = require("//OS/System/Event")

---@alias Core.Logger.LogLevel
---|-1 Trace
---|0 Debug
---|1 Info
---|2 Warning
---|3 Error
---|4 Fatal
---|5 Write (like normal log, but with the source of log call)

---@enum Core.Logger.LogLevel.ToName
local LogLevelToName = {
    [-1] = "Trace",
    [0] = "Debug",
    [1] = "Info",
    [2] = "Warning",
    [3] = "Error",
    [4] = "Fatal",
    [5] = "Write"
}

---@class SphinxOS.System.Logging.Logger : object
---@field OnLog SphinxOS.System.Event
---@field OnClear SphinxOS.System.Event
---@field Name string
---@field private m_logLevel Core.Logger.LogLevel
---@overload fun(name: string, logLevel: Core.Logger.LogLevel, onLog: SphinxOS.System.Event?, onClear: SphinxOS.System.Event?) : SphinxOS.System.Logging.Logger
local Logger = {}

---@param node table
---@param maxLevel number?
---@param properties string[]?
---@param level number?
---@param padding string?
---@return string[]
local function tableToLineTree(node, maxLevel, properties, level, padding)
    padding = padding or '     '
    maxLevel = maxLevel or 5
    level = level or 1
    local lines = {}

    if type(node) == 'table' and not Utils.Class.IsClass(node) then
        local keys = {}
        if type(properties) == 'string' then
            local propSet = {}
            for p in string.gmatch(properties, '%b{}') do
                local propName = string.sub(p, 2, -2)
                for k in string.gmatch(propName, '[^,%s]+') do
                    propSet[k] = true
                end
            end
            for k in next, node, nil do
                if propSet[k] then
                    keys[#keys + 1] = k
                end
            end
        else
            for k in next, node, nil do
                if not properties or properties[k] then
                    keys[#keys + 1] = k
                end
            end
        end

        for i, k in ipairs(keys) do
            local line = ''
            if i == #keys then
                line = padding .. '└── ' .. tostring(k)
            else
                line = padding .. '├── ' .. tostring(k)
            end
            table.insert(lines, line)

            if level < maxLevel then
                ---@cast properties string[]
                local childLines = tableToLineTree(node[k], maxLevel, properties, level + 1,
                    padding .. (i == #keys and '    ' or '│   '))
                for _, l in ipairs(childLines) do
                    table.insert(lines, l)
                end
            elseif i == #keys then
                table.insert(lines, padding .. '└── ...')
            end
        end
    else
        table.insert(lines, padding .. tostring(node))
    end

    return lines
end

---@private
---@param name string
---@param logLevel Core.Logger.LogLevel
---@param onLog SphinxOS.System.Event?
---@param onClear SphinxOS.System.Event?
function Logger:__init(name, logLevel, onLog, onClear)
    self.m_logLevel = logLevel
    self.Name = (string.gsub(name, ' ', '_') or '')
    self.OnLog = onLog or Event()
    self.OnClear = onClear or Event()
end

---@param name string
---@return SphinxOS.System.Logging.Logger
function Logger:subLogger(name)
    name = self.Name .. '.' .. name
    local logger = Logger(name, self.m_logLevel)
    return self:CopyListenersTo(logger)
end

---@param logger SphinxOS.System.Logging.Logger
---@return SphinxOS.System.Logging.Logger logger
function Logger:CopyListenersTo(logger)
    self.OnLog:CopyTo(logger.OnLog)
    self.OnClear:CopyTo(logger.OnClear)
    return logger
end

---@param obj any
---@return string messagePart
local function formatMessagePart(obj)
    if obj == nil then
        return "nil"
    end

    if type(obj) == "table" then
        if Utils.Class.IsClass(obj) then
            return tostring(obj)
        end

        local str = tostring(obj)
        for _, line in ipairs(tableToLineTree(obj)) do
            str = str .. "\n" .. line
        end
        return str
    end

    return tostring(obj)
end

---@param ... any
---@return string?
local function formatMessage(...)
    local messages = { ... }
    if #messages == 0 then
        return
    end
    local message = ""
    for i, messagePart in pairs(messages) do
        if i == 1 then
            message = formatMessagePart(messagePart)
        else
            message = message .. "\n" .. formatMessagePart(messagePart)
        end
    end
    return message
end

---@param logLevel Core.Logger.LogLevel
---@param ... any
function Logger:Log(logLevel, ...)
    if logLevel < self.m_logLevel then
        return
    end

    local message = formatMessage(...)
    if not message then
        return
    end

    if logLevel ~= 10 then
        message = ({ computer.magicTime() })[2] .. " [" .. LogLevelToName[logLevel] .. "]: " .. self.Name .. "\n"
            .. "    " .. message:gsub("\n", "\n    ")
    else
        message = message:gsub("\n", "\n    "):gsub("\r", "\n")
    end
    self.OnLog:Trigger(nil, message .. "\n")
end

---@param t table
---@param logLevel Core.Logger.LogLevel
---@param maxLevel integer?
---@param properties string[]?
function Logger:LogTable(t, logLevel, maxLevel, properties)
    if logLevel < self.m_logLevel then
        return
    end

    if t == nil or type(t) ~= 'table' then
        return
    end

    local str = ""
    for _, line in ipairs(tableToLineTree(t, maxLevel, properties)) do
        str = str .. "\n" .. line
    end
    self:Log(logLevel, str)
end

function Logger:Clear()
    self.OnClear:Trigger()
end

---@param logLevel Core.Logger.LogLevel
function Logger:FreeLine(logLevel)
    if logLevel < self.m_logLevel then
        return
    end

    self.OnLog:Trigger(self, "\n")
end

---@param ... any
function Logger:LogTrace(...)
    self:Log(-1, ...)
end

---@param ... any
function Logger:LogDebug(...)
    self:Log(0, ...)
end

---@param ... any
function Logger:LogInfo(...)
    self:Log(1, ...)
end

---@param ... any
function Logger:LogWarning(...)
    self:Log(2, ...)
end

---@param ... any
function Logger:LogError(...)
    self:Log(3, ...)
end

function Logger:LogFatal(...)
    self:Log(4, ...)
end

function Logger:LogWrite(...)
    self:Log(5, ...)
end

return Utils.Class.Create(Logger, "SphinxOS.System.Logging.Logger")
