local FileSystem = require("tools.Freemaker.bin.filesystem")
local Path = require("tools.Freemaker.bin.path")

local LoaderFiles = {
	'Github-Loading',
	{
		'Loader',
		{
			'Utils',
			{
				"Class",
				{ "00_Config.lua" },
				{ "20_Instance.lua" },
				{ "20_Object.lua" },
				{ "30_Members.lua" },
				{ "30_Type.lua" },
				{ "40_Metatable.lua" },
				{ "50_Construction.lua" },
				{ "80_Index.lua" }
			},
			{ '10_File.lua' },
			{ '10_Function.lua' },
			{ '10_String.lua' },
			{ '10_Table.lua' },
			{ '20_Value.lua' },
			{ '100_Index.lua' }
		},
		{ "10_ComputerLogger.lua" },
		{ "10_Entities.lua" },
		{ "10_Event.lua" },
		{ "10_Module.lua" },
		{ "10_Option.lua" },
		{ "120_Listener.lua" },
		{ "120_Package.lua" },
		{ "140_Logger.lua" },
		{ "200_PackageLoader.lua" },
		{ "300_Overrides.lua" }
	},
	{ '00_Options.lua' },
	{ 'Version.latest.txt' }
}

local FileTreeTools = {}

---@private
---@param parentPath Freemaker.FileSystem.Path
---@param entry table | string
---@param fileFunc fun(path: Freemaker.FileSystem.Path) : boolean
---@param folderFunc fun(path: Freemaker.FileSystem.Path) : boolean
---@return boolean
function FileTreeTools:doEntry(parentPath, entry, fileFunc, folderFunc)
	if #entry == 1 then
		---@cast entry string
		return self:doFile(parentPath, entry, fileFunc)
	else
		---@cast entry table
		return self:doFolder(parentPath, entry, fileFunc, folderFunc)
	end
end

---@private
---@param parentPath Freemaker.FileSystem.Path
---@param file string
---@param func fun(path: Freemaker.FileSystem.Path) : boolean
---@return boolean
function FileTreeTools:doFile(parentPath, file, func)
	local path = parentPath:Extend(file[1])
	return func(path)
end

---@param parentPath Freemaker.FileSystem.Path
---@param folder table
---@param fileFunc fun(path: Freemaker.FileSystem.Path) : boolean
---@param folderFunc fun(path: Freemaker.FileSystem.Path) : boolean
---@return boolean
function FileTreeTools:doFolder(parentPath, folder, fileFunc, folderFunc)
	local path = parentPath:Extend(folder[1])
	if not folderFunc(path) then
		return false
	end
	for index, child in pairs(folder) do
		if index ~= 1 then
			local success = self:doEntry(path, child, fileFunc, folderFunc)
			if not success then
				return false
			end
		end
	end
	return true
end

---@param loaderBasePath string
---@return table<string, any[]> loadedLoaderFiles
local function loadFiles(loaderBasePath)
	---@type string[][]
	local loadEntries = {}
	---@type integer[]
	local loadOrder = {}
	---@type table<string, any[]>
	local loadedLoaderFiles = {}

	---@param path Freemaker.FileSystem.Path
	---@return boolean success
	local function retrievePath(path)
		local pathStr = path:ToString()
		local fileName = path:GetFileName()
		local num = fileName:match('^(%d+)_.+$')
		if num then
			num = tonumber(num)
			---@cast num integer
			local entries = loadEntries[num]
			if not entries then
				entries = {}
				loadEntries[num] = entries
				table.insert(loadOrder, num)
			end
			table.insert(entries, pathStr)
		else
			local file = FileSystem.OpenFile(loaderBasePath .. pathStr, 'r')
			if not file then
				error("unable to open file: " .. loaderBasePath .. pathStr)
			end
			local str = ''
			while true do
				local buf = file:read(4096)
				if not buf then
					break
				end
				str = str .. buf
			end
			local foundPath = pathStr:match('^(.+/.+)%..+$')
			loadedLoaderFiles[foundPath] = { str }
			file:close()
		end

		return true
	end

	assert(
		FileTreeTools:doFolder(
			Path.new(""),
			LoaderFiles,
			retrievePath,
			function()
				return true
			end
		),
		'Unable to load loader Files'
	)

	table.sort(loadOrder)
	for _, num in ipairs(loadOrder) do
		for _, path in pairs(loadEntries[num]) do
			local loadedFile = { loadfile(loaderBasePath .. path)(loadedLoaderFiles) }
			local folderPath,
			filename = path:match('^(.+)/%d+_(.+)%..+$')
			if filename == 'Index' then
				loadedLoaderFiles[folderPath] = loadedFile
			else
				loadedLoaderFiles[folderPath .. '/' .. filename] = loadedFile
			end
		end
	end

	return loadedLoaderFiles
end

return loadFiles
