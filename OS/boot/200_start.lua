local Process = require("/OS/System/Threading/Process")

local function main()
    --//TODO: is like a watchdog

    --//TODO: start up terminal
end

local mainProcess = Process(main, {
    parent = false,
    environment = {
        workingDirectory = "/",
    },
})
mainProcess:Prepare()
local code = mainProcess:Execute()

if mainProcess:IsSuccess() then
    print("OS shutdown with code: " .. (code or 0))
else
    print(mainProcess:GetError())
end
