--[[
    This is what is called after the kernel finishes!
]]

--[[
local gpu = ...

gpu.set(1, 2, "OS Started!")
]]--

local gpu = kernsig("get_data", "display_main")
gpu.set(1, 2, "OS Started! :)")
gpu.set(1, 3, "Kernel signals are working!")