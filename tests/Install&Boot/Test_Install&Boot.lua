local luaunit = require('tools.Testing.Luaunit')

local FileSystem = require("tools.Freemaker.bin.filesystem")

local currentPath = FileSystem:GetCurrentDirectory()

local installFilePath = currentPath .. "/../../install/eeprom.lua"

local bootFilePath = currentPath .. "/../../OS/boot/eeprom.lua"
local eepromFile = io.open(currentPath .. "/../../install/eeprom.lua", "r")
if not eepromFile then
    error("unable to open install.eeprom")
end
local eeprom = eepromFile:read("a")
eepromFile:close()


function TestInstall()
    local Sim = require('tools.Testing.Simulator'):Initialize(nil, eeprom, true)

    dofile(installFilePath)
end

function TestBoot()
    local Sim = require('tools.Testing.Simulator'):Initialize(currentPath .. "/../..", eeprom)

    dofile(bootFilePath)
end

os.exit(luaunit.LuaUnit.run())
