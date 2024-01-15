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

print("boot complete!")

--//TODO: load OS maybe boot order of files (like FicsIt-OS) or just hardcoded

local bootEntries = {}
local bootOrder = {}
local bootFolder = "/boot"
local loadedBootFiles = {}

for _, child in pairs(filesystem.childs(bootFolder)) do
    if not child:find(".boot.", nil, true) then
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
    else
        local file = filesystem.open(bootFolder .. path, 'r')
        local str = ''
        while true do
            local buf = file:read(8192)
            if not buf then
                break
            end
            str = str .. buf
        end
        path = path:match('^(.+/.+)%..+$')
        loadedBootFiles[path] = { str }
        file:close()
    end

    ::continue::
end

table.sort(bootOrder)
for _, num in ipairs(bootOrder) do
    for _, path in pairs(bootEntries[num]) do
        local loadedFile = { filesystem.loadFile(bootFolder .. path)(loadedBootFiles) }
        local folderPath,
        filename = path:match('^(.+)/%d+_(.+)%..+$')
        if filename == 'Index' then
            loadedBootFiles[folderPath] = loadedFile
        else
            loadedBootFiles[folderPath .. '/' .. filename] = loadedFile
        end
    end
end

-- to invoke gc
computer.stop()
