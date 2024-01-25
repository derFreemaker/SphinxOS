local luaunit = require('tools.Testing.Luaunit')
local Sim = require('tools.Testing.Simulator'):Initialize()

local Thread = require("//OS/System/Threading/Thread")

function TestThreadExecution()
    local testThread = Thread(
        function()
            print("test complete")
        end
    )
    testThread:Execute()
end

function TestThreadStop()
    local testThread = Thread(
    ---@param thread SphinxOS.System.Threading.Thread
        function(thread)
            thread:Kill()
        end
    )
    testThread:Execute(testThread)
end

function TestThreadMultiStop()
    local expectedCode = 123

    local mainTestThread

    local function foo1()
        mainTestThread:Kill(expectedCode)
    end

    local testThread1 = Thread(foo1)

    local function foo2()
        testThread1:Execute()
    end

    local testThread2 = Thread(foo2)

    local function test()
        testThread2:Execute()
    end

    mainTestThread = Thread(test)
    local success, results = mainTestThread:Execute(mainTestThread)

    luaunit.assertIsTrue(success)
    luaunit.assertEquals(results[1], expectedCode)
end

----------------------------------------------------------------
-- resume tests are technically not needed its not intended to be resumed once it exits
----------------------------------------------------------------

function TestThreadResume()
    local expectedResults = {}

    local testThread = Thread(
    ---@param thread SphinxOS.System.Threading.Thread
        function(thread)
            thread:Kill()
            return expectedResults
        end
    )
    testThread:Execute(testThread)

    local success, results = testThread:Execute()

    luaunit.assertIsTrue(success)
    luaunit.assertEquals(results[1], expectedResults)
end

function TestThreadMultiResume()
    local expectedCode = 123

    local mainTestThread

    local function foo1()
        mainTestThread:Kill(expectedCode)
        error("lol")
    end

    local testThread1 = Thread(foo1)

    local function foo2()
        testThread1:Execute()
        return testThread1:Execute()
    end

    local testThread2 = Thread(foo2)

    local function test()
        testThread2:Execute()
        return testThread2:Execute()
    end

    mainTestThread = Thread(test)
    local success, results = mainTestThread:Execute()

    luaunit.assertIsTrue(success)
    luaunit.assertEquals(results[1], expectedCode)

    local success1, results1 = mainTestThread:Execute()

    luaunit.assertIsTrue(success1)
    luaunit.assertIsFalse(results1[1])
end

os.exit(luaunit.LuaUnit.run())
