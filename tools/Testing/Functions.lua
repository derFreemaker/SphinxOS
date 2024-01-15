---@param func fun(num: integer?)
---@param amount integer
local function benchmarkFunction(func, amount)
    local startTime = os.clock()

    for i = 1, amount, 1 do
        func(i)
    end

    local endTime = os.clock()
    local totalTime = endTime - startTime

    print('total time: ' .. totalTime .. 's amount: ' .. amount)
    print('each time : ' .. (totalTime / amount) * 1000 * 1000 * 1000 .. 'ns')
end

---@param func function
---@param amount integer
local function captureFunction(func, amount)
    local startTime = os.clock()

    func()

    local endTime = os.clock()
    local totalTime = endTime - startTime

    print('total time: ' .. totalTime .. 's amount: ' .. amount)
    print('each time : ' .. (totalTime / amount) * 1000 * 1000 * 1000 .. 'ns')
end

return { benchmarkFunction = benchmarkFunction, captureFunction = captureFunction }
