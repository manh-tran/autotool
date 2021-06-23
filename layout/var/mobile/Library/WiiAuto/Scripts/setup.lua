local json = require "json"

local exist = isFileExist("/private/var/mobile/Library/WiiAuto/Scripts/script_manager.at")
if exist == false then
    exeCmd("mkdir -p /private/var/mobile/Library/WiiAuto/Scripts/script_manager.at")
    exeCmd("cd /private/var/mobile/Library/WiiAuto/Scripts/script_manager.at && git init && git remote add github https://mtd-bit:ccd8106f90e7227b7dbf5c88d76e5e275d2a2d12@github.com/mtd-bit/script_manager.git && git pull github master")
else
    local path = "/private/var/mobile/Library/WiiAuto/Scripts/script_manager.at"
    exeCmd("cd " .. path .. " && git remote set-url github https://mtd-bit:ccd8106f90e7227b7dbf5c88d76e5e275d2a2d12@github.com/mtd-bit/script_manager.git")
    exeCmd("cd " .. path .. " && git config --local user.email \"m@m\" && git config --local user.name \"mtd\" && git stash")
    exeCmd("cd " .. path .. " && git pull github master")
end