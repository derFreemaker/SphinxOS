local luaunit = require('tools.Testing.Luaunit')

local Curl = require("tools.Curl")
local Installer = require("install.installer")
local InstallFilesIndex = require("install.files")

local FileSystem = require("tools.Freemaker.bin.filesystem")

local currentPath = FileSystem:GetCurrentDirectory()

local bootFilePath = currentPath .. "/../../OS/boot/eeprom.lua"
local eepromFile = io.open(currentPath .. "/../../install/eeprom.lua", "r")
if not eepromFile then
    error("unable to open install.eeprom")
end
local eeprom = eepromFile:read("a")
eepromFile:close()

local Sim = require('tools.Testing.Simulator'):Initialize(nil, eeprom, true)

local BASE_URL = "http://localhost"
-- local BASE_URL = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/main"
local BASE_PATH = ""

-- Paths
local OS_PATH = "/OS"

local INSTALL_PATH = OS_PATH .. "/install"
local BOOT_PATH = OS_PATH .. "/boot"

local INSTALL_EEPROM_PATH = INSTALL_PATH .. "/eeprom.lua"
local BOOT_EEPROM_PATH = BOOT_PATH .. "/eeprom.lua"

function TestInstall()
    if not filesystem.exists(INSTALL_PATH) and not filesystem.createDir(INSTALL_PATH) then
        error("unable to create install folder")
    end

    local installer = Installer.new(BASE_URL, BASE_PATH, BOOT_EEPROM_PATH, Curl, InstallFilesIndex)

    print("downloading OS files...")
    installer:Download()

    print("saving current eeprom to " .. INSTALL_EEPROM_PATH .. " for later use...")
    local installFile = filesystem.open(INSTALL_EEPROM_PATH, "w")
    installFile:write(computer.getEEPROM())
    installFile:close()

    print("writing boot loader to eeprom...")
    installer:LoadBootLoader()

    print("installed!")
end

function TestRunBoot()
    dofile(bootFilePath)
end

os.exit(luaunit.LuaUnit.run())
