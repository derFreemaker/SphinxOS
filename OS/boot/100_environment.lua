--//TODO: configure default environment properly

local environment = require("/OS/System/Threading/Environment")
environment.Static__Default = function()
    return environment()
end
