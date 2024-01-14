-- //TODO: hold up-to date
local OSFiles = {
    "SphinxOS",
    {
        "boot",
        { "boot.lua" }
    }
}

---@class SphinxOS.Installer.FileTreeTools
---@field m_fileFunc fun(path: string) : boolean
---@field m_folderFunc fun(path: string) : boolean
local FileTreeTools = {}

---@param fileFunc fun(path: string) : boolean
---@param folderFunc fun(path: string) : boolean
function FileTreeTools.new(fileFunc, folderFunc)
    return setmetatable({
        m_fileFunc = fileFunc,
        m_folderFunc = folderFunc
    }, { __index = FileTreeTools })
end

---@private
---@param parentPath string
---@param entry table
---@return boolean
function FileTreeTools:doEntry(parentPath, entry)
    if #entry == 1 then
        return self:doFile(parentPath, entry)
    else
        ---@cast entry table
        return self:doFolder(parentPath, entry)
    end
end

---@private
---@param parentPath string
---@param file table
---@return boolean
function FileTreeTools:doFile(parentPath, file)
    local path = parentPath .. file[1]
    return self.m_fileFunc(path)
end

---@param parentPath string
---@param folder table
---@return boolean
function FileTreeTools:doFolder(parentPath, folder)
    local path = parentPath .. folder[1] .. "/"
    if not self.m_folderFunc(path) then
        return false
    end
    for index, child in pairs(folder) do
        if index ~= 1 then
            local success = self:doEntry(path, child)
            if not success then
                return false
            end
        end
    end
    return true
end

---@class SphinxOS.Installer.DownloadRequest
---@field get fun(self: SphinxOS.Installer.DownloadRequest) : integer, string

---@param url string
---@param internetCard FIN.Components.InternetCard_C
---@return fun() : integer, string?
local function startDownloadRequest(url, internetCard)
    local req = internetCard:request(url, 'GET', '')

    return function()
        repeat
        until req:canGet()
        return req:get()
    end
end

---@class SphinxOS.Installer
---@field m_baseUrl string
---@field m_basePath string
---@field m_bootPath string
---@field m_internetCard FIN.Components.InternetCard_C
local Installer = {}

---@param baseUrl string
---@param basePath string
---@param bootPath string
---@param internetCard FIN.Components.InternetCard_C
---@return SphinxOS.Installer
function Installer.new(baseUrl, basePath, bootPath, internetCard)
    -- //WARN: computer.promote used
    computer.promote()

    return setmetatable({
        m_baseUrl = baseUrl,
        m_basePath = basePath,
        m_bootPath = bootPath,
        m_internetCard = internetCard,
    }, { __index = Installer })
end

function Installer:Download()
    ---@type (fun())[]
    local requests = {}

    ---@param path string
    ---@return boolean
    local function downloadFile(path)
        local url = self.m_baseUrl .. path
        path = self.m_basePath .. path

        local req = startDownloadRequest(url, self.m_internetCard)
        local processReq = function()
            local code, data = req()
            if code ~= 200 or data == nil then
                error("unable to download: " .. url)
            end

            local file = filesystem.open(path, "w")
            if file == nil then
                error("unable to open path: " .. path)
            end

            file:write(data)
            file:close()
        end
        table.insert(requests, processReq)

        return true
    end

    ---@param path string
    ---@return boolean
    local function createFolder(path)
        return filesystem.createDir(self.m_basePath .. path, true)
    end

    local downloadFileTreeTools = FileTreeTools.new(downloadFile, createFolder)
    downloadFileTreeTools:doFolder("/", OSFiles)

    for _, request in ipairs(requests) do
        request()
    end
end

function Installer:LoadBootLoader()
    local file = filesystem.open(self.m_bootPath, "r")

    local bootStr = ""
    while true do
        local buf = file:read(4096)
        if not buf then
            break
        end
        bootStr = bootStr .. buf
    end
    file:close()

    computer.setEEPROM(bootStr)
end

return Installer
