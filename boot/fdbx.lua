--[[
    Frosty Debug Terminal
]]

--  // Get the needed things
local _, gpu = kernsig("get_data", "display_main")
local _, tty = kernsig("get_data", "tty_main")

local termrun = true

--  // Command Handler
function rs()
    tty:clear()
    tty:println("Frosty Debug Terminal")
    tty:println("Version 1.0.0a")
end

function command_handler(line_in)
    local line = line_in:lower()
    if line == "version" then
        tty:println("littlesuit 1.0.0a")
    elseif line == "exit" then
        termrun = false
    elseif line == "clear" then
        rs()
    elseif line == "help" then
        tty:println("Commands:")
        tty:println("version")
        tty:println("exit")
        tty:println("clear")
        tty:println("help")
    else
        tty:println("Unknown command!")
    end
end

--  // Clear the screen
rs()

--  // Accept Commands
local line = ""
while termrun do
    tty:print("> ")
    line = tty:readLine()
    tty:println("")
    --tty:println(line or "??????")
    command_handler(line)
end
tty:printn("Closing terminal...")