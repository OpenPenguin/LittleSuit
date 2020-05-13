--[[
    LittleSuit Kernel
    Developed by Ethan Manzi
]]

--  Define some important information variables
_G._OSVERSION = "LittleSuit 1.0.0"
_G._KERNEL = "LittleSuit"

local _kernel_memory_ = {
    ["processes"] = {},
    ["users"] = {
        ["kerneluser-root"] = {
            ["uuid"] = "kerneluser-root",
            ["username"] = "root",
            ["password"] = nil,
            ["groups"] = {"kernelgroup-sudo"},
            ["flags"] = {"kernelowned","nologin"},
            ["permissions"] = {"*"}
        },
        ["kerneluser-guest"] = {
            ["uuid"] = "kerneluser-guest",
            ["username"] = "guest",
            ["password"] = nil,
            ["groups"] = {},
            ["flags"] = {"kernelowned","nologin"},
            ["permissions"] = {}
        }
    },
    ["groups"] = {
        ["kernelgroup-sudo"] = {
            ["uuid"] = "kernelgroup-sudo",
            ["name"] = "sudo",
            ["flags"] = {"kernelowned", "rootable"},
            ["permissions"] = {"*"}
        },
        ["kernelgroup-user"] = {
            ["uuid"] = "kernelgroup-users",
            ["name"] = "users",
            ["flags"] = {"kernelowned"},
            ["permissions"] = {}
        }
    },
    ["sockets"] = {},
    ["pipes"] = {},
    ["states"] = {
        ["running"] = true
    },
    ["components"] = {},
    ["data"] = {}
}

--  Define some generic helpers
function define(variable, defaultVariable)
    if variable == nil then
        return defaultVariable
    end
    return variable
end
function getFirstDefined(variables, defaultVariable)
    for _, value in paris(variables) do
        if value ~= nil then
            return value
        end
    end
    return defaultVariable
end
function generateUUID()

end

--  Create sandboxing systems
local _Sandbox_G = nil

function run_sandbox(sb_env, sb_func, ...)
    local sb_orig_env=_ENV
    if (not sb_func) then return nil end
    _ENV=sb_env
    local sb_ret={e.pcall(sb_func, ...)}
    _ENV=sb_orig_env
    return e.table.unpack(sb_ret)
end

--  Get the raw filesystem
local rfs = component.proxy(computer.getBootAddress())

--  Create user systems
    function createUser(invoker, username, password, groups, flags, permissions)
        groups = define(password, {})
        flags = define(flags, {})
        permissions = define(permissions, {})
    end
    function deleteUser(invoker, userID)

    end
    function lookupUser(invoker, username)

    end
    function getUserInfo(invoker, userID)

    end
    function addUserToGroup(invoker, userID, groupID)

    end
    function removeUserFromGroup(invoker, userID, groupID)

    end
    function setUserFlag(invoker, userID, flag)

    end
    function removeUserFlag(invoker, userID, flag)

    end
    function grantUserPermission(invoker, userID, permission)
    
    end
    function revokeUserPermission(invoker, userID, permission)

    end
--  Create group systems
    function createGroup(invoker, name, flags, permissions)

    end
    function deleteGroup(invoker, groupID)

    end
    function setGroupFlag(invoker, groupID, flag)

    end
    function removeGroupFlag(invoker, groupID, flag)

    end
    function grantGropPermission(invoker, groupID, permission)
    
    end
    function revokeGropPermission(invoker, groupID, permission)

    end
--  Create process systems
    function spawnProcess(enviroment, func, ...)
        local t = coroutine.create(function()
            if (enviroment == nil) then
                -- No sandbox!
                pcall(func, ...)
            else
                -- Yes sandbox!
                run_sandbox(enviroment, func, ...)
            end
        end)
        coroutine.resume(t)
        return t
    end
    function createProcess(invoker, processEntryMethod, env)

    end
    function getProcessInfo(invoker, processID)

    end
    function startProcess(invoker, processID, arguments)

    end
    function killProcess(invoker, processID)

    end

--  Create IPC systems
--  [ Messaging ]
    function publishMessage(invoker, ...)
        --computer.pushSignal("ipc_message_" .. channel, sender, ...)
    end
    function subscribeToMessages(invoker, callback)

    end
    --[[
        function listenForMessage(channel, callback)
            callback(table.unpack(computer.pullSignal("ipc_message_" .. channel)))
        end
    ]]
--  [ Pipes ]
    function createPipe(invoker, bind1, bind2) {
        
    }

    function _examplePipeBind_(pipe)
        --  pipe:onWrite([ignoreSelf: Boolean = true], callback: (...) -> Void) -> Void
        pipe:onWrite(true, function(...)
            -- invoked when the pipe is written to!
            local data = {...}
            print("They said " + data[1])
        end)

        --  pipe:onClose(callback: () -> Void) -> Void
        pipe:onClose(function()
            -- invoked when the pipe is closed!
        end)

        --  pipe:write(data: ...) -> Void
        pipe:write("Hello world!")

        --  pipe:close() -> Void
        pipe:close()
    end

--  [ Channels ]
    function createChannel(invoker)

    end
    function deleteChannel(invoker, channelID)

    end
    function writeToChannel(invoker, channelID, ...)

    end
    function grantChannelWritePermission(invoker, channelID, targetID)
        -- targetID is either the UUID of a process, user, group, or it is the literal "all"
    end
    function revokeChannelWritePermission(invoker, channelID, targetID)
        -- targetID is either the UUID of a process, user, group, or it is the literal "all"
    end
    function inviteToChannel(invoker, channelID, targetID)
        -- targetID is either the UUID of a process, user, or group.
    end
    function publishChannel(invoker, channelID, channelName, target)
        -- target is either the UUID of a process, user, group, the literal "all", or nil.
        -- If the target is either "all" or nil, then the channel is available to anyone.
    end
    function unpublishChannel(invoker, channelID)
        -- unpublishes the channel
    end
    function lookupChannel(invoker, channelName)
        -- tries to find a published channel by that name, and if found returns the UUID, otherwise returns nil
    end
    function subcribeToChannel(invoker, channelID)

    end
    function subcribeToChannelInvite(invoker)
        -- Fired when invited to a channel
    end

--  [ Sockets ]
    function createSocket(invoker, name)
        -- if a name is provided, the socket will automatically be published
    end
    function publishSocket(invoker, socketID, name)

    end
    function lookupSocket(invoker, socketName)
        -- tries to find a published socket by that name, and if found returns the UUID, otherwise returns nil
    end
    function subcribeToSocket(invoker, socketID, callback)

    end
    function writeToSocket(invoker, socketID, ...)

    end


    --  Create kernel 'interrupt' method
function kernel_signal(job, ...)
    local arguments = {...}

end

--========================[ Define API Wrappers for Kernel Methods ]========================--

--================================[ Define Default Sandbox ]================================--
_Sandbox_G = {
    --  Standard Lua Enviroment
    ipairs = ipairs,
    next = next,
    pairs = pairs,
    pcall = pcall,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack,
    coroutine = {
        create = coroutine.create, 
        resume = coroutine.resume, 
        running = coroutine.running, 
        status = coroutine.status, 
        wrap = coroutine.wrap 
    },
    string = { 
        byte = string.byte, 
        char = string.char, 
        find = string.find, 
        format = string.format, 
        gmatch = string.gmatch, 
        gsub = string.gsub, 
        len = string.len, 
        lower = string.lower, 
        match = string.match, 
        rep = string.rep, 
        reverse = string.reverse, 
        sub = string.sub, 
        upper = string.upper },
    table = { 
        insert = table.insert, 
        maxn = table.maxn, 
        remove = table.remove, 
        sort = table.sort
    },
    math = {
        abs = math.abs, 
        acos = math.acos, 
        asin = math.asin, 
        atan = math.atan, 
        atan2 = math.atan2, 
        ceil = math.ceil, 
        cos = math.cos, 
        cosh = math.cosh, 
        deg = math.deg, 
        exp = math.exp, 
        floor = math.floor, 
        fmod = math.fmod, 
        frexp = math.frexp,
        huge = math.huge, 
        ldexp = math.ldexp, 
        log = math.log, 
        log10 = math.log10, 
        max = math.max, 
        min = math.min, 
        modf = math.modf, 
        pi = math.pi, 
        pow = math.pow, 
        rad = math.rad, 
        random = math.random, 
        sin = math.sin, 
        sinh = math.sinh, 
        sqrt = math.sqrt, 
        tan = math.tan, 
        tanh = math.tanh 
    },
    os = { 
        clock = os.clock, 
        difftime = os.difftime, 
        time = os.time
    }
    --  Custom Objects
    
}



--====================================[ Start OS Level ]====================================--


--[[
    Create signal handler loop
    The loop will run so long as the system's `running` flag is set. THis loop is required, otherwise the system will halt!
]]
while _kernel_memory_["states"]["running"] do

end
