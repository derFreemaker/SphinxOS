local FileSystem = require("tools.Freemaker.bin.filesystem")
local Path = require("tools.Freemaker.bin.path")

local CurrentPath = Path.new(FileSystem.GetCurrentDirectory())
    :GetParentFolderPath()
    :GetParentFolderPath()

local Sim = require('tools.Testing.Simulator'):Initialize(CurrentPath)
Sim:OverrideRequire()

---@diagnostic disable
Utils = require("/OS/misc/utils")
Utils.Class = require("/OS/misc/classSystem")
---@diagnostic enable

local Buffer = require("/OS/System/IO/Buffer")
local Stream = require("/OS/System/IO/Stream")
local ConsoleInStreamAdapter = require("/tools/Testing/Adapter/ConsoleInStreamAdapter")

local Process = require("/OS/System/Process")

local testBuffer = Buffer()
local testStream = Stream(testBuffer)

local function foo(str)
    local currentProcess = Process.Static__Running()

    currentProcess.stdOut:Write("id: '" .. currentProcess.ID .. "' data: '" .. str .. "'")

    ---@diagnostic disable-next-line
    if currentProcess.m_parent then
        ---@diagnostic disable-next-line
        currentProcess.stdOut:Write(" parentID: '" .. currentProcess.m_parent.ID .. "'")
    end

    currentProcess.stdOut:Write("\n")
    currentProcess.stdOut:Flush()

    local process = require("/System/Process")

    if currentProcess.ID < 5 then
        local test = Process(foo, { stdOut = testStream })
        test:Execute(str)
    end
end

local test = Process(foo, { parent = false, stdOut = ConsoleInStreamAdapter(), workingDirectory = "/OS" })
test:Execute("Hi")

if not test:IsSuccess() then
    print(test:Traceback())
end

-- testStream:Write("hi")
-- testStream:Write("asd")
-- testStream:Close()

print("buffer:")
io.stdout:write(testBuffer:Read())
io.stdout:flush()

print("### END ###")
