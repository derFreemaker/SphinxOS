local Process = require("//OS/System/Threading/Process")

local Terminal = require("//OS/System/Terminal")

local function main()
    --//TODO: is like a watchdog

    --//TODO: start up terminal

    local terminal = Terminal()
end

local mainProcess = Process(main, {
    parent = false,
    environment = {
        workingDirectory = "/",
    },
})
local code = mainProcess:Execute()

if mainProcess:IsSuccess() then
    print("OS shutdown with code: " .. (code or 0))
else
    print(mainProcess:GetError())
end
