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

-- to invoke gc
computer.stop()
