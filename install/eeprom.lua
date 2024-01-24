local BASE_URL = "http://localhost"
-- local BASE_URL = "https://raw.githubusercontent.com/derFreemaker/SphinxOS/main"
local BASE_PATH = ""

-- Urls
local INSTALL_URL = BASE_URL .. "/install"
local INSTALLER_URL = INSTALL_URL .. "/installer.lua"
local INSTALL_FILES_URL = INSTALL_URL .. "/files.lua"

local OS_URL = "/OS"

-- Paths
local INSTALL_PATH = "/install"
local INSTALLER_PATH = INSTALL_PATH .. "/installer.lua"
local INSTALL_FILES_PATH = INSTALL_PATH .. "/files.lua"
local INSTALL_EEPROM_PATH = INSTALL_PATH .. "/eeprom.lua"

local OS_PATH = "/SphinxOS"
local BOOT_PATH = OS_PATH .. "/boot/eeprom.lua"

local internetCard
do
    print("### initializing... ###")

    internetCard = computer.getPCIDevices(classes.InternetCard_C)[1]
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
end
do
    print("### downloading... ###")
    do
        print("### downloading installer... ###")

        local req = internetCard:request(INSTALLER_URL, "GET", "")
        local code, data = req:await()
        if not code == 200 then
            error("unable to get installer file from " .. INSTALLER_URL)
        end

        local installerFile = filesystem.open(INSTALLER_PATH, "w")
        installerFile:write(data)
        installerFile:close()
    end

    do
        print("### downloading install files list... ###")

        local req = internetCard:request(INSTALL_FILES_URL, "GET", "")
        local code, data = req:await()
        if not code == 200 then
            error("unable to get installer file from " .. INSTALL_FILES_URL)
        end

        local installerFile = filesystem.open(INSTALL_FILES_PATH, "w")
        installerFile:write(data)
        installerFile:close()
    end

    print("### download complete ###")
end

local installer
do
    print("### loading... ###")

    ---@type SphinxOS.Installer
    installer = filesystem.doFile(INSTALLER_PATH)
    installer = installer.new(OS_URL, BASE_PATH, BOOT_PATH, internetCard, filesystem.doFile(INSTALL_FILES_PATH))

    print("### loaded ###")
end

do
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
end
