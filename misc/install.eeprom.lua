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

print("### initializing... ###")

local internetCard = computer.getPCIDevices(classes.InternetCard_C)[1]
if not internetCard then
    computer.beep(0.2)
    error('No internet-card found!')
    return
end
filesystem.initFileSystem('/dev')
local drive = ""
for _, child in pairs(filesystem.childs('/dev')) do
    if child ~= "serial" then
        drive = child
        break
    end
end
if drive:len() < 1 then
    computer.beep(0.2)
    error('Unable to find filesystem to load on! Insert a drive or floppy.')
    return
end
filesystem.mount('/dev/' .. drive, '/')

print("### initialized ###")
print("### downloading Installer... ###")

local req = internetCard:request(INSTALLER_URL, "GET", "")
local code, data = req:await()
if not code == 200 then
    error("unable to get installer file from " .. INSTALLER_URL)
end

local installerFile = filesystem.open(INSTALLER_PATH, "w")
installerFile:write(data)
installerFile:close()

print("### download complete ###")

print("### loading... ###")

---@type SphinxOS.Installer
local installer = filesystem.doFile(INSTALLER_PATH)
installer = installer.new(OS_URL, BASE_PATH, BOOT_PATH, internetCard)

print("### loaded ###")

print("### installing... ###")

print("downloading OS files...")
installer:Download()

print("saving current eeprom to " .. INSTALL_EEPROM_PATH .. " for later use...")
local installFile = filesystem.open(INSTALL_EEPROM_PATH, "w")
installFile:write(computer.getEEPROM())
installFile:close()

print("writing boot loader to eeprom...")
installer:LoadBootLoader()

print("### installed ###")
