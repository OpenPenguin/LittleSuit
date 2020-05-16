--[[
    This is what is called after the kernel finishes!
]]

--[[
local gpu = ...

gpu.set(1, 2, "OS Started!")
]]--

--_ENV.getCurrentProcessID()

--[[
local gpu = kernsig("get_data", "display_main")
gpu.set(1, 2, "OS Started! :)")
gpu.set(1, 3, "Kernel signals are working!")
]]--

local gpu = ...

local w, h = gpu.maxResolution()

local function clr()
    gpu.setResolution(w, h)
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")
end
clr()

gpu.set(1, 1, "OS DEBUGGER!")

local y = 2
for index, value in pairs(_ENV) do
    local voff = string.len(index)
    gpu.set(1, y, index)
    gpu.set(voff + 5, y, tostring(value))
    y = y + 1

    if y > h then
        clr()
        y = 2
    end
end