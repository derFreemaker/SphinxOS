local Process = require("/OS/System/Threading/Process")

local function main()
    --//TODO: is like a watchdog

    --//TODO: start up terminal
end

local mainProcess = Process(main, { parent = false, workingDirectory = "/" })
