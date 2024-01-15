local FileSystem = require("tools.Freemaker.bin.filesystem")
local Path = require("tools.Freemaker.bin.path")

---@param file file*
---@return FIN.Filesystem.File
local function newFile(file)
    ---@type FIN.Filesystem.File
    local instance = {
        m_file = file
    }

    ---@diagnostic disable-next-line
    function instance:close()
        self.m_file:close()
    end

    ---@param length integer
    ---@return string
    ---@diagnostic disable-next-line
    function instance:read(length)
        return self.m_file:read(length)
    end

    ---@param mode FIN.Filesystem.File.SeekMode
    ---@param offset integer?
    ---@return integer offset
    ---@diagnostic disable-next-line
    function instance:seek(mode, offset)
        local seek = self.m_file:seek(mode, offset)
        return seek
    end

    ---@param data string
    ---@diagnostic disable-next-line
    function instance:write(data)
        self.m_file:write(data)
    end

    return instance
end

---@type Freemaker.FileSystem.Path
local FileSystemPath
local Initialized = false

local function initializeFileSystem()
    if Initialized then
        return
    end

    if not FileSystemPath:Exists() and not FileSystemPath:Create() then
        error("unable to initialize filesystem")
    end

    Initialized = true
end

---@param fileSystemPath Freemaker.FileSystem.Path
return function(fileSystemPath)
    filesystem = {}
    FileSystemPath = fileSystemPath

    ---@param path string
    ---@return boolean success
    ---@diagnostic disable-next-line
    function filesystem.initFileSystem(path)
        initializeFileSystem()
        return true
    end

    ---@param device string
    ---@param mountPoint string
    ---@diagnostic disable-next-line
    function filesystem.mount(device, mountPoint)
    end

    ---@param path string
    ---@return string[] childs
    ---@diagnostic disable-next-line
    function filesystem.childs(path)
        initializeFileSystem()

        if path == "/dev" then
            return { "%FakeDrive%" }
        end

        local dirs = FileSystem.GetDirectories(fileSystemPath:Extend(path):ToString())
        local files = FileSystem.GetFiles(path)
        return { table.unpack(dirs), table.unpack(files) }
    end

    ---@diagnostic disable-next-line
    filesystem.children = filesystem.childs

    ---@param path string
    ---@diagnostic disable-next-line
    function filesystem.exists(path)
        initializeFileSystem()

        return fileSystemPath:Extend(path):Exists()
    end

    ---@param path string
    ---@param mode FIN.Filesystem.File.Openmode
    ---@return FIN.Filesystem.File
    ---@diagnostic disable-next-line
    function filesystem.open(path, mode)
        initializeFileSystem()

        path = fileSystemPath:Extend(path):ToString()

        ---@type seekwhence
        local whence = "set"

        ---@diagnostic disable
        ---@cast mode openmode

        if mode == "a" then
            mode = "w"
            whence = "end"
        elseif mode == "+r" then
            mode = "w+"
        elseif mode == "+a" then
            mode = "a"
        end

        local file = io.open(path, mode)

        ---@diagnostic enable

        if not file then
            error("Unable to open file: " .. path)
        end

        file:seek(whence, 0)

        return newFile(file)
    end

    ---@param path string
    ---@param all boolean
    ---@diagnostic disable-next-line
    function filesystem.createDir(path, all)
        initializeFileSystem()

        return FileSystem.CreateFolder(fileSystemPath:Extend(path):ToString())
    end

    ---@param parameter FIN.Filesystem.PathParameters | string
    ---@param ... string
    ---@return string
    ---@diagnostic disable-next-line
    function filesystem.path(parameter, ...)
        if type(parameter) == "string" then
            local paths = { ... }
            local path = Path.new(parameter)

            for _, value in pairs(paths) do
                path:Append(value)
            end

            return path:ToString()
        end

        local paths = { ... }
        local path = Path.new()

        for _, value in pairs(paths) do
            path:Append(value)
        end

        if parameter == 0 then
            return path:Normalize():ToString()
        end

        if parameter == 1 then
            return path:Normalize():Absolute():ToString()
        end

        if parameter == 2 then
            return path:Normalize():Relative():ToString()
        end

        if parameter == 3 then
            return path:GetFileName()
        end

        if parameter == 4 then
            return path:GetFileStem()
        end

        if parameter == 5 then
            return path:GetFileExtension()
        end

        error(tostring(parameter) .. " is not supported")
    end

    ---@param path string
    ---@diagnostic disable-next-line
    function filesystem.loadFile(path)
        initializeFileSystem()

        return loadfile(fileSystemPath:Extend(path):ToString())
    end

    ---@param path string
    ---@diagnostic disable-next-line
    function filesystem.doFile(path)
        initializeFileSystem()

        return dofile(fileSystemPath:Extend(path):ToString())
    end
end
