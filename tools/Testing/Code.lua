local FileSystem = require("tools.Freemaker.bin.filesystem")
local Path = require("tools.Freemaker.bin.path")
local CurrentPath = Path.new(FileSystem.GetCurrentDirectory())
    :GetParentFolderPath()
    :GetParentFolderPath()
local Sim, MainProcess = require('tools.Testing.Simulator'):InitializeWithOS(CurrentPath)
print("MainProcess PID: " .. MainProcess.PID .. "\n")

local Buffer = require("/OS/System/IO/Buffer")
local Stream = require("/OS/System/IO/Stream")

local Environment = require("/OS/System/Threading/Environment")
local Process = require("/OS/System/Threading/Process")
local Task = require("/OS/System/Threading/Task")

local testBuffer = Buffer()
local testStream = Stream(testBuffer)

---@param str string
---@param task SphinxOS.System.Threading.Task?
local function foo(str, task)
    local currentProcess = Process.Static__Running()

    currentProcess.StdOut:Write("id: '" .. currentProcess.PID .. "' data: '" .. str .. "'")

    ---@diagnostic disable-next-line
    if currentProcess.m_parent then
        ---@diagnostic disable-next-line
        currentProcess.StdOut:Write(" parentID: '" .. currentProcess.m_parent.ID .. "'")
    end

    currentProcess.StdOut:Write("\n")
    currentProcess.StdOut:Flush()

    if task then
        task:Execute(currentProcess.PID)
        print(Environment.Static__Current().workingDirectory)
    end

    local process = require("/System/Threading/Process")

    if currentProcess.PID < 6 then
        local test = process(foo)
        test:Execute(str, task)

        if not test:IsSuccess() then
            print("error in process PID: " .. test.PID)
            print(test:Traceback())
        end
    end
end

local testTask = Task(
    function(id)
        print(Environment.Static__Current().workingDirectory)

        if id == 4 then
            MainProcess:Kill()
        end
    end
)

local test = Process(foo, {
    stdOut = testStream,
    environment = {
        workingDirectory = "/OS"
    }
})
test:Execute("Hi", testTask)

if not test:IsSuccess() then
    print(test:Traceback())
end

MainProcess.StdOut:Write("\nbuffer:\n")
MainProcess.StdOut:Write(testBuffer:Read() .. "\n")
MainProcess.StdOut:Flush()

print(MainProcess.StdIn:Read("l"))

print("### END ###")

--//TODO: make a lot of tests
