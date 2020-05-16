--[[
    This is what is called after the kernel finishes!
]]
local _, gpu = kernsig("get_data", "display_main")
gpu.set(1, 2, "OS Started! :)")
gpu.set(1, 3, "Kernel signals are working!") 

-- sleep(3)

local _, tty = kernsig("get_data", "tty_main")
tty.clear(tty)
tty:println("Hello World!")
tty:println("OS is working fine!")
tty:println("Kernel signals are amazing!")
tty:println("And the TTY library is great!")

-- kernsig("shutdown")
kernsig("get_get_clock_tick")

tty:println("Press any key to load the terminal...")
tty:getCharacter()

local _, term_pid = kernsig("create_process", "/boot/fdbx.lua")
kernsig("set_data_for", term_pid, "tty_main", tty)
kernsig("set_data_for", term_pid, "display_main", gpu)
kernsig("start_process", term_pid)