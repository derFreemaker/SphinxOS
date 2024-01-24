local luaunit = require('tools.Testing.Luaunit')
local Sim = require('tools.Testing.Simulator'):Initialize()

local Process = require("OS.System.Threading.Process")

function TestProcessNormal()
    local testProcess = Process(
        function()
            print("hi")
        end
    )
    testProcess:Execute()
end

os.exit(luaunit.LuaUnit.run())
