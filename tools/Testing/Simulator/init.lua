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
	---@param path string
	function require(path)
		local result = { requireFunc(path) }
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

---@param fileSystemPath (string | Freemaker.FileSystem.Path)?
---@param eeprom string?
---@return Test.Simulator
function Simulator:Initialize(fileSystemPath, eeprom)
	if fileSystemPath == nil then
		local info = debug.getinfo(2)
		fileSystemPath = Path.new(info.source)
			:GetParentFolderPath()
			:Append("Sim-Files")
	elseif type(fileSystemPath) == "string" then
		fileSystemPath = Path.new(fileSystemPath)
	end

	self:prepare(fileSystemPath, eeprom or "")

	return self
end

return Simulator
