--//TODO: write tests to test stop and other functions of process while in task

local luaunit = require('tools.Testing.Luaunit')
local Sim = require('tools.Testing.Simulator'):Initialize()

local Environment = require("//OS/System/Threading/Environment")()
__ENV.ENV = Environment.Static__Default()

local Task = require("//OS/System/Threading/Task")

function TestTaskNormal()
    local expectedResult = {}

    local testTask = Task(
        function()
            return expectedResult
        end
    )

    local result = testTask:Execute()

    luaunit.assertIsTrue(testTask:IsSuccess())
    luaunit.assertEquals(result, expectedResult)
end

function TestTaskStop()
    local testTask
    testTask = Task(
        function()
            testTask:Kill(false)
        end
    )

    local result = testTask:Execute()

    luaunit.assertIsTrue(testTask:IsSuccess())
    luaunit.assertIsFalse(result)
end

function TestTaskMultiStop()
    local expectedResult = { 10 }

    local testTask
    testTask = Task(
        function()
            local testTask2 = Task(
                function()
                    local testTask1 = Task(
                        function()
                            testTask:Kill(expectedResult)
                        end
                    )

                    testTask1:Execute()
                end
            )

            testTask2:Execute()
        end
    )

    local result = testTask:Execute()

    luaunit.assertIsTrue(testTask:IsSuccess())
    luaunit.assertEquals(result, expectedResult)
end

os.exit(luaunit.LuaUnit.run())
