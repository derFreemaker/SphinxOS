local luaunit = require('tools.Testing.Luaunit')

local Curl = require("tools.Curl")
local Installer = require("install.installer")
local InstallFilesIndex = require("install.files")

local FileSystem = require("tools.Freemaker.bin.filesystem")
local currentPath = FileSystem:GetCurrentDirectory()
local FileSystemPath = currentPath .. "/Sim-Files"

local bootFilePath = currentPath .. "/../../SphinxOS/boot/boot.lua"
local eepromFile = io.open(currentPath .. "/../install/eeprom.lua", "r")
if not eepromFile then
    error("unable to open install.eeprom")
end
local eeprom = eepromFile:read("a")
eepromFile:close()

local Sim = require('tools.Testing.Simulator'):Initialize(FileSystemPath, eeprom)

local BASE_URL = "http://localhost"
-- local BASE_URL = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/main"
local BASE_PATH = ""

-- Urls
local OS_URL = BASE_URL .. "/SphinxOS"

local MISC_URL = OS_URL .. "/misc"
local INSTALLER_URL = MISC_URL .. "/installer.lua"

-- Paths
local OS_PATH = "/SphinxOS"

local INSTALL_PATH = "/install"
local INSTALL_EEPROM_PATH = INSTALL_PATH .. "/install.eeprom.lua"
local INSTALLER_PATH = INSTALL_PATH .. "/installer.lua"

local BOOT_PATH = OS_PATH .. "/boot/boot.lua"

function TestInstall()
    if not filesystem.exists(INSTALL_PATH) and not filesystem.createDir(INSTALL_PATH) then
        error("unable to create install folder")
    end

    local installer = Installer.new(BASE_URL, BASE_PATH, "/SphinxOS/boot/boot.lua", Curl, InstallFilesIndex)

    print("downloading OS files...")
    installer:Download()

    print("saving current eeprom to " .. INSTALL_EEPROM_PATH .. " for later use...")
    local installFile = filesystem.open(INSTALL_EEPROM_PATH, "w")
    installFile:write(computer.getEEPROM())
    installFile:close()

    print("writing boot loader to eeprom...")
    installer:LoadBootLoader()

    print("installed!")

    dofile(bootFilePath)
end

function TestRunBoot()
    local installer = Installer.new(BASE_URL, BASE_PATH, "/SphinxOS/boot/boot.lua", Curl, InstallFilesIndex)

    print("writing boot loader to eeprom...")
    installer:LoadBootLoader()

    dofile(bootFilePath)
end

os.exit(luaunit.LuaUnit.run())
