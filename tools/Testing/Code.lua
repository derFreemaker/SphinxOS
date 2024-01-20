local FileSystem = require("tools.Freemaker.bin.filesystem")
local Path = require("tools.Freemaker.bin.path")
local CurrentPath = Path.new(FileSystem.GetCurrentDirectory())
    :GetParentFolderPath()
    :GetParentFolderPath()
local Sim = require('tools.Testing.Simulator'):Initialize(CurrentPath)

local Buffer = require("/OS/System/IO/Buffer")
local Stream = require("/OS/System/IO/Stream")
local ConsoleOutStreamAdapter = require("/tools/Testing/Adapter/ConsoleOutStreamAdapter")

local Environment = require("/OS/System/Threading/Environment")
local Process = require("/OS/System/Threading/Process")
local Task = require("/OS/System/Threading/Task")

local testBuffer = Buffer()
local testStream = Stream(testBuffer)

---@param str string
---@param task SphinxOS.System.Threading.Task?
local function foo(str, task)
    local currentProcess = Process.Static__Running()

    currentProcess.stdOut:Write("id: '" .. currentProcess.ID .. "' data: '" .. str .. "'")

    ---@diagnostic disable-next-line
    if currentProcess.m_parent then
        ---@diagnostic disable-next-line
        currentProcess.stdOut:Write(" parentID: '" .. currentProcess.m_parent.ID .. "'")
    end

    currentProcess.stdOut:Write("\n")
    currentProcess.stdOut:Flush()

    if task then
        task:Execute()
        print(Environment.Static__Current().workingDirectory)
    end

    local process = require("/System/Threading/Process")

    if currentProcess.ID < 9 then
        local test = process(foo, {
            stdOut = testStream
        })
        test:Execute(str, task)

        if not test:IsSuccess() then
            print("error in process PID: " .. test.ID)
            print(test:Traceback())
        end
    end
end

local testTask = Task(
    function()
        print(Environment.Static__Current().workingDirectory or "/")
    end
)

local test = Process(foo, {
    stdOut = ConsoleOutStreamAdapter(),
    environment = {
        workingDirectory = "/OS"
    }
})
test:Execute("Hi", testTask)

if not test:IsSuccess() then
    print(test:Traceback())
end

-- testStream:Write("hi")
-- testStream:Write("asd")
-- testStream:Close()

print("buffer:")
io.stdout:write(testBuffer:Read())
io.stdout:flush()

print(require("/OS/System/Event"))

print("### END ###")
