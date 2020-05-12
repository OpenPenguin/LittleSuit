--[[
    LittleSuit Kernel
    Developed by Ethan Manzi
]]

--  Define some important information variables
_G._OSVERSION = "LittleSuit 1.0.0"
_G._KERNEL = "LittleSuit"

local _kernel_memory_ = {}

--  Get the raw filesystem
local rfs = component.proxy(computer.getBootAddress())

--  Create sandboxing systems
local _Sandbox_G = {}

function createENV()

end
function spawnSandbox(code, env)
    
end

--  Create process systems

--  Create IPC systems
--  [ Messaging ]
function sendMessage(channel, sender, ...)
    computer.pushSignal("ipc_message_" .. channel, sender, ...)
end
function listenForMessage(channel, callback)
    callback(table.unpack(computer.pullSignal("ipc_message_" .. channel)))
end
--  [ Pipes ]

