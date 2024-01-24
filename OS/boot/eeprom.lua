event.ignoreAll()
event.clear()

--//WARN: computer.promote used
computer.promote()

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

local bootEntries = {}
local bootOrder = {}
local bootFolder = "/OS/boot"

for _, child in pairs(filesystem.childs(bootFolder)) do
    if child:find(".eeprom.", nil, true) then
        goto continue
    end

    local path = filesystem.path(bootFolder, child)
    local fileName = child
    local num = fileName:match('^(%d+)_.+$')
    if num then
        num = tonumber(num)
        ---@cast num integer
        local entries = bootEntries[num]
        if not entries then
            entries = {}
            bootEntries[num] = entries
            table.insert(bootOrder, num)
        end
        table.insert(entries, path)
    end

    ::continue::
end

table.sort(bootOrder)
for _, num in ipairs(bootOrder) do
    for _, path in pairs(bootEntries[num]) do
        local func = filesystem.loadFile(path)
        func()
    end
end

-- to invoke gc
if not NotInGame then
    computer.stop()
end
