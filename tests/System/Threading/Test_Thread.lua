local luaunit = require('tools.Testing.Luaunit')
local Sim = require('tools.Testing.Simulator'):Initialize()

local Thread = require("OS.System.Threading.Thread")

function TestThreadExecution()
    local co = coroutine.create(
        function()
            print("test complete")
        end
    )

    local testThread = Thread(co)
    testThread:Execute()
end

os.exit(luaunit.LuaUnit.run())
