local FileSystem = require("tools.Freemaker.bin.filesystem")
local Path = require("tools.Freemaker.bin.path")

local args = { ... }
local searchFolder = Path.new(args[1]) or error("#1: no search folder provided")
local outputFilePath = args[2] or error("#2: no search output file path provided")

local outputFile = FileSystem.OpenFile(outputFilePath, "w") or error("unable to open outputFilePath: " .. outputFilePath)

---@param path Freemaker.FileSystem.Path
---@param indent string
local function indexFile(path, indent)
    local fileName = path:GetFileName()

    outputFile:write(indent .. "{ \"" .. fileName .. "\" },\n")
end

---@param path Freemaker.FileSystem.Path
---@param indent string
local function indexFolder(path, indent)
    indent = indent .. "\t"
    local folderName = path:GetDirectoryName()
    outputFile:write(indent .. "\"" .. folderName .. "\",\n")

    for _, folder in ipairs(FileSystem.GetDirectories(path:ToString())) do
        outputFile:write(indent .. "{\n")
        indexFolder(path:Extend(folder), indent)
        outputFile:write(indent .. "},\n")
    end
    for _, file in ipairs(FileSystem.GetFiles(path:ToString())) do
        indexFile(path:Extend(file), indent)
    end
end

print("writing...")

outputFile:write("return {\n")

indexFolder(searchFolder, "")

outputFile:write("}\n")

print("done!")
