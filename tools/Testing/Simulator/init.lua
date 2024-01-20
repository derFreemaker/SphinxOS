-- local FileSystem = require("tools.Freemaker.bin.filesystem")
local Path = require("tools.Freemaker.bin.path")

local loadClassesAndStructs = require("tools.Testing.Simulator.classes&structs")
local loadFileSystem = require("tools.Testing.Simulator.filesystem")
local loadComputer = require("tools.Testing.Simulator.computer")
local loadComponent = require("tools.Testing.Simulator.component")
local loadEvent = require("tools.Testing.Simulator.event")

---@class Test.Simulator
---@field private m_loadedLoaderFiles table<string, any[]>
local Simulator = {}

---@private
local function setupRequire()
	filesystem.doFile("/OS/System/Require.lua")
end

local function setupUtils()
	Utils = require("/OS/misc/utils")
	Utils.Class = require("/OS/misc/classSystem")
end

local function setupMainProcess()
	local environment = require("//OS/System/Threading/Environment")
	environment.Static__Default = function()
		return environment()
	end

	local consoleInStreamAdapter = require("//tools/Testing/Adapter/ConsoleInStreamAdapter")
	local process = require("//OS/System/Threading/Process")

	---@diagnostic disable-next-line
	local main = process(nil, { parent = false, stdOut = consoleInStreamAdapter() })
	main:Prepare()
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
	setupRequire()
	setupUtils()
	setupMainProcess()
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
