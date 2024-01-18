local sim = require('tools.Testing.Simulator'):Initialize()
sim:OverrideRequire()

---@diagnostic disable
Utils = require("/OS/misc/utils")
Utils.Class = require("/OS/misc/classSystem")
---@diagnostic enable

local Buffer = require("/OS/System/IO/Buffer")
local Stream = require("/OS/System/IO/Stream")
local ConsoleInStreamAdapter = require("/tools/Testing/Adapter/ConsoleInStreamAdapter")

local Process = require("/OS/System/Process")

local function foo(str)
    local currentProcess = Process.Static__Running()

    ---@diagnostic disable-next-line
    if currentProcess.m_parent then
        ---@diagnostic disable-next-line
        currentProcess.stdOut:Write(currentProcess.ID .. str .. currentProcess.m_parent.ID .. "\n")
    else
        currentProcess.stdOut:Write(currentProcess.ID .. str .. "\n")
    end
    currentProcess.stdOut:Flush()

    if currentProcess.ID < 5 then
        local test = Process(foo)
        test:Execute(str)
    end
end

-- local testBuffer = Buffer()
-- local testStream = Stream(testBuffer)

local test = Process(foo, false, { stdOut = ConsoleInStreamAdapter() })
test:Execute("Hi")

if not test:IsSuccess() then
    print(test:Traceback())
end

-- testStream:Write("hi")
-- testStream:Write("asd")
-- testStream:Close()

-- io.stdout:write(testBuffer:Read())
-- io.stdout:flush()

print("### END ###")
