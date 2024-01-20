---@param str string
---@return string str
local function formatStr(str)
    str = str:gsub("\\", "/")
    return str
end

---@class SphinxOS.System.FileSystem.Path : object
---@field m_nodes string[]
---@overload fun(pathOrNodes: (string | string[])?) : SphinxOS.System.FileSystem.Path
local Path = {}

---@alias SphinxOS.System.FileSystem.Path.__init fun(pathOrNodes: (string | string[])?)

---@private
---@param pathOrNodes (string | string[])?
function Path:__init(pathOrNodes)
    if not pathOrNodes then
        self.m_nodes = {}
        return
    end

    if type(pathOrNodes) == "string" then
        pathOrNodes = formatStr(pathOrNodes)
        pathOrNodes = Utils.String.Split(pathOrNodes, "/")
    end

    local length = #pathOrNodes
    local node = pathOrNodes[length]
    if node and node ~= "" and not node:find("^.+%..+$") then
        pathOrNodes[length + 1] = ""
    end

    self.m_nodes = pathOrNodes
end

---@param str string
---@return boolean isNode
function Path.Static__IsNode(str)
    if str:find("/") then
        return false
    end

    return true
end

---@return string path
function Path:ToString()
    self:Normalize()
    return Utils.String.Join(self.m_nodes, "/")
end

---@return boolean
function Path:IsEmpty()
    return #self.m_nodes == 0 or (#self.m_nodes == 2 and self.m_nodes[1] == "" and self.m_nodes[2] == "")
end

---@return boolean
function Path:IsFile()
    return self.m_nodes[#self.m_nodes] ~= ""
end

---@return boolean
function Path:IsDir()
    return self.m_nodes[#self.m_nodes] == ""
end

function Path:Exists()
    return filesystem.exists(self:ToString())
end

---@return boolean
function Path:Create()
    if self:Exists() then
        return true
    end

    if self:IsDir() then
        return filesystem.createDir(self:ToString())
    elseif self:IsFile() then
        local success, file = pcall(filesystem.open, self:ToString(), "w")
        if not success then
            return false
        end

        file:close()
        return true
    end

    return false
end

---@return boolean
function Path:IsAbsolute()
    if #self.m_nodes == 0 then
        return false
    end

    if self.m_nodes[1] == "" then
        return true
    end

    if self.m_nodes[1]:find(":", nil, true) then
        return true
    end

    return false
end

---@return SphinxOS.System.FileSystem.Path
function Path:Absolute()
    local copy = Utils.Table.Copy(self.m_nodes)

    for i = 1, #copy, 1 do
        copy[i] = copy[i + 1]
    end

    return Path(copy)
end

---@return boolean
function Path:IsRelative()
    if #self.m_nodes == 0 then
        return false
    end

    return self.m_nodes[1] ~= "" and not (self.m_nodes[1]:find(":", nil, true))
end

---@return SphinxOS.System.FileSystem.Path
function Path:Relative()
    local copy = {}

    if self.m_nodes[1] ~= "" then
        copy[1] = ""
        for i = 1, #self.m_nodes, 1 do
            copy[i + 1] = self.m_nodes[i]
        end
    end

    return Path(copy)
end

---@return string
function Path:GetParentFolder()
    local copy = Utils.Table.Copy(self.m_nodes)
    local length = #copy

    if length > 0 then
        if length > 1 and copy[length] == "" then
            copy[length] = nil
            copy[length - 1] = ""
        else
            copy[length] = nil
        end
    end

    return Utils.String.Join(copy, "/")
end

---@return SphinxOS.System.FileSystem.Path
function Path:GetParentFolderPath()
    local copy = self:Copy()
    local length = #copy.m_nodes

    if length > 0 then
        if length > 1 and copy.m_nodes[length] == "" then
            copy.m_nodes[length] = nil
            copy.m_nodes[length - 1] = ""
        else
            copy.m_nodes[length] = nil
        end
    end

    return copy
end

---@return string fileName
function Path:GetFileName()
    if not self:IsFile() then
        error("path is not a file: " .. self:ToString())
    end

    return self.m_nodes[#self.m_nodes]
end

---@return string fileExtension
function Path:GetFileExtension()
    if not self:IsFile() then
        error("path is not a file: " .. self:ToString())
    end

    local fileName = self.m_nodes[#self.m_nodes]

    local _, _, extension = fileName:find("^.+(%..+)$")
    return extension
end

---@return string fileStem
function Path:GetFileStem()
    if not self:IsFile() then
        error("path is not a file: " .. self:ToString())
    end

    local fileName = self.m_nodes[#self.m_nodes]

    local _, _, stem = fileName:find("^(.+)%..+$")
    return stem
end

---@return SphinxOS.System.FileSystem.Path
function Path:Normalize()
    ---@type string[]
    local newNodes = {}

    for index, value in ipairs(self.m_nodes) do
        if value == "." then
        elseif value == "" then
            if index == 1 or index == #self.m_nodes then
                newNodes[#newNodes + 1] = ""
            end
        elseif value == ".." then
            if index ~= 1 then
                newNodes[#newNodes] = nil
            end
        else
            newNodes[#newNodes + 1] = value
        end
    end

    if newNodes[1] then
        newNodes[1] = newNodes[1]:gsub("@", "")
    end

    self.m_nodes = newNodes
    return self
end

---@param path string
---@return SphinxOS.System.FileSystem.Path
function Path:Append(path)
    if self.m_nodes[#self.m_nodes] == "" then
        self.m_nodes[#self.m_nodes] = nil
    end

    path = formatStr(path)
    local newNodes = Utils.String.Split(path, "/")

    for _, value in ipairs(newNodes) do
        self.m_nodes[#self.m_nodes + 1] = value
    end

    if self.m_nodes[#self.m_nodes] ~= "" and not self.m_nodes[#self.m_nodes]:find("^.+%..+$") then
        self.m_nodes[#self.m_nodes + 1] = ""
    end

    self:Normalize()

    return self
end

---@param path string
---@return SphinxOS.System.FileSystem.Path
function Path:Extend(path)
    local copy = self:Copy()
    return copy:Append(path)
end

---@return SphinxOS.System.FileSystem.Path
function Path:Copy()
    local copyNodes = Utils.Table.Copy(self.m_nodes)
    return Path(copyNodes)
end

return Utils.Class.Create(Path, "SphinxOS.System.FileSystem.Path")
