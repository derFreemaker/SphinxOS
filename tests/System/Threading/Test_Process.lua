local luaunit = require('tools.Testing.Luaunit')
local Sim = require('tools.Testing.Simulator'):Initialize()

local Process = require("//OS/System/Threading/Process")

function TestProcessNormal()
    local testProcess = Process(
        function()
            print("hi")
        end
    )
    testProcess:Execute()
end

function TestProcessStop()
    local testProcess = Process(
        function()
            Process.Static__Running():Kill(false)
        end
    )

    local result = testProcess:Execute()

    luaunit.assertIsTrue(testProcess:IsSuccess())
    luaunit.assertIsFalse(result)
end

function TestProcessMultiStop()
    local expectedResult = { 10 }

    local testProcess
    testProcess = Process(
        function()
            local testProcess2 = Process(
                function()
                    local testProcess1 = Process(
                        function()
                            testProcess:Kill(expectedResult)
                        end
                    )

                    testProcess1:Execute()
                end
            )

            testProcess2:Execute()
        end
    )

    local result = testProcess:Execute()

    luaunit.assertIsTrue(testProcess:IsSuccess())
    luaunit.assertEquals(result, expectedResult)
end

os.exit(luaunit.LuaUnit.run())
