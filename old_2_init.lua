--[[
    LittleSuit Kernel
    Developed by Ethan Manzi
]]

--  Define some important information variables
_G._OSVERSION = "LittleSuit 1.0.0"
_G._KERNEL = "LittleSuit"

--  Define important kernel arrays
local components = {}
local groups = {}
local users = {} -- User IDs BEGIN at 100
local temp_users = {} -- Users used just for sandboxing and things
local processes = {}
local sockets = {}
local socket_connections = {}
local drivers = {}

local privileges = {
    [0] = "Guest",
    [1] = "User",
    [2] = "Sudo",
    [3] = "Root",
    [4] = "Kernel"
}

local system_users = {
    {
        ["id"] = 0,
        ["username"] = "kernel",
        ["privilegeLevel"] = 4,
        ["privileges"] = {} -- This user doesn't need to specify permissions
    },
    {
        ["id"] = 1
        ["username"] = "root",
        ["privilegeLevel"] = 3,
        ["privileges"] = {}  -- This user doesn't need to specify permissions
    }
}

local supermethods = {} --  Methods that should be exposed globally to all software
local privileged_supermethods = {}

--  Define some code for working with signals
local function fireSignal(name, ...)
    computer.pushSignal(name, ...)
end
local function pullSignalAsync(name, callback)
    local result = computer.pullSignal(name)
    callback(table.unpack(result))
end
local function pullSignal(name, timeout)
    return computer.pullSignal(name, timeout)
end

--  Define the system for managing events, signals, etc.
local function findFirstFreeSocketID()
    local i = 1
    local target
    repeat
        target = sockets[i]
        i = i + 1
    until target == nil
    return i
end
local function findFirstFreeSocketConnectionID()
    local i = 1
    local target
    repeat
        target = socket_connections[i]
        i = i + 1
    until target == nil
    return i
end
local function findFirstFreeProcessID()
    local i = 1
    local target
    repeat
        target = processes[i]
        i = i + 1
    until target == nil
    return i
end

local function createSocket(invokingUser, invokingProcess, isSocketHidden)
    local socketid = findFirstFreeSocketID()
    sockets[socketid] = {["id"] = socketid, ["owner"] = invokingUser, ["hidden"] = isSocketHidden, ["process"] = invokingProcess, ["connections"] = {}}
    return socketid
end

local function listSockets()
    return sockets
end

local function subscribeToSocket(invokingUser, invokingProcess, socketHandle, callback)
    assert(sockets[socketHandle], 0x74)
    local ID = findFirstFreeSocketConnectionID()
    socket_connections[ID] = {["id"] = ID, ["owner"] = invokingUser, ["process"] = invokingProcess, ["callback"] = callback}
    table.insert(socket[socketHandle]["connections"], ID)
    return ID
end

local function subscriptionDelegate(PID)
    local function handle(socketID, invokingProcess, ...)
        local socket = sockets[socketID]
        for _, subID in pairs(socket["connections"]) do
            socket_connections[subID]["callback"](invokingProcess, ...)
        end
    repeat
        handle(computer.pullSignal("socketsignal"))
    until not processes[PID]["alive"]
end

--  Define the process controllers
local function spawnProcess(invokingUser, invokingProcess, method, ...)
    local newPID = findFirstFreeProcessID()
    processes[newPID] = {
        ["owner"] = invokingUser,
        ["process"] = invokingProcess,
        ["method"] = method,
        ["thread"] = coroutine.create(method),
        ["alive"] = true
    }
    coroutine.resume(processes[newPID]["thread"], newPID, ...)
    return newPID
end
local function killProcess(PID)
    -- TODO?
end

--  Define the systems to working with privileges
local function createUser(config)

end
local function deleteUser(userID)

end
local function getUser(userID)
    if userID <= 100 then
        --  System user
    else
        --  Normal user
    end
end
local function loadUserPermissions(userID)

end
local function setUserPermission(userID, permission, value)

end
local function checkForPermissions(userID, privilege)
    --  Privileges will look like this => system.socket.create
end

----------[ Master Kernel Start ]----------
spawnProcess(0, 0, subscriptionDelegate)