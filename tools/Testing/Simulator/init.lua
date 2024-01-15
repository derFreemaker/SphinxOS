local FileSystem = require("tools.Freemaker.bin.filesystem")
local Path = require("tools.Freemaker.bin.path")

local loadClassesAndStructs = require("tools.Testing.Simulator.classes&structs")
local loadFileSystem = require("tools.Testing.Simulator.filesystem")
local loadComputer = require("tools.Testing.Simulator.computer")
local loadComponent = require("tools.Testing.Simulator.component")
local loadEvent = require("tools.Testing.Simulator.event")

local CurrentPath = ''

---@class Test.Simulator
---@field private m_loadedLoaderFiles table<string, any[]>
local Simulator = {}

local requireFunc = require --[[@as fun(moduleName: string)]]
function Simulator:OverrideRequire()
	---@param moduleToGet string
	function require(moduleToGet)
		local result = { requireFunc("src." .. moduleToGet) }
		if type(result[#result]) == "string" then
			result[#result] = nil
		end
		return table.unpack(result)
	end
end

---@private
---@param fileSystemPath Freemaker.FileSystem.Path
---@param eeprom string
function Simulator:prepare(fileSystemPath, eeprom)
	loadClassesAndStructs()
	loadComputer(eeprom)
	loadFileSystem(fileSystemPath)
	loadComponent()
	loadEvent()

	self:OverrideRequire()
end

---@param fileSystemPath string?
---@param eeprom string?
---@return Test.Simulator
function Simulator:Initialize(fileSystemPath, eeprom)
	local simulatorPath = FileSystem.GetCurrentDirectory()
	CurrentPath = simulatorPath:gsub("tools/Testing/Simulator", "")

	if not fileSystemPath then
		local info = debug.getinfo(2)
		fileSystemPath = Path.new(info.source)
			:GetParentFolderPath()
			:Append("Sim-Files")
			:ToString()
	end

	self:prepare(Path.new(fileSystemPath), eeprom or "")

	return self
end

return Simulator
