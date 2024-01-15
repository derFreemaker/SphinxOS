---@param ... any data
---@return Test.Curl.Future
local function newFuture(...)
    ---@class Test.Curl.Future
    local instance = { m_data = { ... } }

    function instance:await()
        return table.unpack(self.m_data)
    end

    function instance:canGet()
        return true
    end

    function instance:get()
        return table.unpack(self.m_data)
    end

    return instance
end

---@class Test.Curl : FIN.Components.InternetCard_C
local Curl = {}

---@param url string
---@param method FIN.Components.FINComputerMod.FINInternetCard.HttpMethods
---@param data string
function Curl:request(url, method, data)
    local tmpFile = "file.tmp"
    local command = [[curl "]]
        .. url .. [["]]
        .. [[ -X ]] .. method
        .. [[ -d "]] .. data .. [["]]
        .. [[ -o "]] .. tmpFile .. [["]]
        .. [[ -i 2> nul]]

    os.execute(command)

    local file = io.open(tmpFile, "r")
    if not file then
        return newFuture(400, "Unable to open file")
    end

    ---@type string
    local reqData = file:read("a")

    file:close()
    os.execute("del " .. tmpFile)

    local headersEndPos = reqData:find("\n\n")
    if not headersEndPos then
        return newFuture(400, "Unable to find headers end pos")
    end

    local onlyHeaderData = reqData:sub(0, headersEndPos)
    local onlyResponseData = reqData:sub(headersEndPos + 2)

    local code = tonumber(onlyHeaderData:match("HTTP/%S+ (%S+) .*"))

    return newFuture(code, onlyResponseData)
end

return Curl
