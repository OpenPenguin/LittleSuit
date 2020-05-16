--[[
    LittleSuit Kernel
    Developed by Ethan Manzi
]]

--  Define some important information variables
_G._OSVERSION = "LittleSuit 1.0.0"
_G._KERNEL = "LittleSuit"

local computer = computer
local _GLOBAL_ENVIROMENT_=_ENV

local UUID_LENGTH = 16

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
    ["messagesubcribers"] = {},
    ["sockets"] = {},
    ["pipes"] = {},
    ["channels"] = {},
    ["published-channels"] = {},
    ["states"] = {
        ["running"] = true,
        ["reboot"] = false
    },
    ["components"] = {},
    ["drivers"] = {},
    ["uuids"] = {},
    ["data"] = {},
    ["timers"] = {},
    ["os-timer-last-tick"] = 0
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
function generateUUID(prefix)
    local symbols = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local output = define(prefix, "m")
    for i=0, UUID_LENGTH do
        local r = math.random(1, (string.len(symbols) - 1))
        output = output .. symbols:sub(r,r)
    end

    local x = (#_kernel_memory_["uuids"] % string.len(symbols)) + 1
    output = output .. symbols:sub(x,x)
    table.insert(_kernel_memory_["uuids"], output)
    return output
end
function tableContainsValue(tbl, target)
    for index, value in pairs(tbl) do
        if value == target then
            return true
        end
    end
    return false
end
function tableContainsIndex(tbl, target)
    for index, value in pairs(tbl) do
        if index == target then
            return true
        end
    end
    return false
end
function getFromTableByIndex(tbl, target)
    for index, value in pairs(tbl) do
        if index == target then
            return index, value
        end
    end
    return nil, nil
end
function getFromTableByValue(tbl, target)
    for index, value in pairs(tbl) do
        if value == target then
            return index, value
        end
    end
    return nil, nil
end
function removeFromTableByValue(tbl, target)
    local index, value = getFromTableByValue(tbl, target)
    table.remove(tbl, index)
end

function loadfile(addr, file, env)
    local handle = assert(component.invoke(addr, "open", file), "Unable to open file!")
    local buffer = ""
    repeat
        local data = component.invoke(addr, "read", handle, math.huge)
        buffer = buffer .. (data or "")
    until not data
    component.invoke(addr, "close", handle)
    return load(buffer, "=" .. file, "bt", env or _G)
end

function importfile(addr, file)
    local program, reason = loadfile(addr, file)
    if program then
      local result = table.pack(pcall(program))
      if result[1] then
        return table.unpack(result, 2, result.n)
      else
        error(result[2] or "fish want to bite my eyes")
      end
    else
      error(reason or "the monkey ate my toes")
    end
  end

--  Create sandboxing systems
local _Sandbox_G = nil

function run_sandbox(sb_env, sb_func, ...)
    local sb_orig_env=_ENV
    if (not sb_func) then return nil end
    _ENV=sb_env
    local sb_ret={_GLOBAL_ENVIROMENT_.pcall(sb_func, ...)}
    _ENV=sb_orig_env
    return _GLOBAL_ENVIROMENT_.table.unpack(sb_ret)
end



--  Get the raw filesystem
local rfs = component.proxy(computer.getBootAddress())
local rfaddr = computer.getBootAddress()

function checkUserHasPermission(userID, permission)
    local user = _kernel_memory_["users"][userID]
    if tableContainsValue(user["permissions"], permission) or tableContainsValue(user["permissions"], "*") then
        return true
    end
    for _, groupID in pairs(user["groups"]) do
        local group = _kernel_memory_["groups"][groupID]
        if tableContainsValue(group["permissions"], permission) or tableContainsValue(group["permissions"], "*") then
            return true
        end
    end
    return false
end
function checkUserHasFlag(userID, flag)
    local user = _kernel_memory_["users"][userID]
    if tableContainsValue(user["flags"], flag) then
        return true
    end
    for _, groupID in pairs(user["groups"]) do
        local group = _kernel_memory_["groups"][groupID]
        if tableContainsValue(group["flags"], flag) then
            return true
        end
    end
    return false
end

function isOwner(UUID, inqueryTarget)
    --[[
        Check if the specified UUID owns the UUID in inqueryTarget.
        This includes going up the hierarchy. If inqueryTarget is a process that's owned by a user, then it should return true.

        TODO!
    ]]
    return true
end

--  Create state storage system
    function save_state()
        -- save things like the users and groups!
    end
    function load_state()
        -- load things like the users and groups!
    end

--  Create user systems
    function createUser(username, password, groups, flags, permissions)
        groups = define(password, {})
        flags = define(flags, {})
        permissions = define(permissions, {})
        local uuid = generateUUID("u")

        _kernel_memory_["users"][uuid] = {
            ["uuid"] = uuid,
            ["username"] = username:lower(),
            ["password"] = password,
            ["groups"] = groups,
            ["flags"] = flags,
            ["permissions"] = permissions
        }

        return uuid
    end
    function deleteUser(userID)
        _kernel_memory_["users"][userID] = nil
    end
    function lookupUser(username)
        for UUID, user in pairs(_kernel_memory_["users"]) do
            if user["username"] == username then
                return UUID
            end
        end
        return nil
    end
    function getUserInfo(userID)
        return _kernel_memory_["users"][userID]
    end
    function addUserToGroup(userID, groupID)
        table.insert(_kernel_memory_["users"][userID]["groups"], groupID)
    end
    function removeUserFromGroup(userID, groupID)
        removeFromTableByValue(_kernel_memory_["users"][userID]["groups"], groupID)
    end
    function setUserFlag(userID, flag)
        table.insert(_kernel_memory_["users"][userID]["flags"], flag)
    end
    function removeUserFlag(userID, flag)
        removeFromTableByValue(_kernel_memory_["users"][userID]["flags"], flag)
    end
    function grantUserPermission(userID, permission)
        table.insert(_kernel_memory_["users"][userID]["permissions"], permission)
    end
    function revokeUserPermission(userID, permission)
        removeFromTableByValue(_kernel_memory_["users"][userID]["permissions"], permission)
    end
--  Create group systems
    function createGroup(name, flags, permissions)
        flags = define(flags, {})
        permissions = define(permissions, {})
        local uuid = generateUUID("g")

        _kernel_memory_["groups"][uuid] = {
            ["uuid"] = uuid,
            ["name"] = name:lower(),
            ["flags"] = flags,
            ["permissions"] = permissions
        }

        return uuid
    end
    function deleteGroup(groupID)
        _kernel_memory_["groups"][groupID] = nil
    end
    function setGroupFlag(groupID, flag)
        table.insert(_kernel_memory_["groups"][groupID]["flags"], flag)
    end
    function removeGroupFlag(groupID, flag)
        removeFromTableByValue(_kernel_memory_["groups"][userID]["flags"], flag)
    end
    function grantGropPermission(groupID, permission)
        table.insert(_kernel_memory_["groups"][groupID]["permissions"], permission)
    end
    function revokeGroupPermission(groupID, permission)
        removeFromTableByValue(_kernel_memory_["groups"][userID]["permissions"], permission)
    end
--  Create process systems
    function spawnProcess(enviroment, func)
        local t = coroutine.create(function(...)
            coroutine.yield(func(...))
        end)
        --coroutine.resume(t)
        return t
    end
    function createProcess(owner, enviroment, funcloader)
        local uuid = generateUUID("p")

        -- add some IMPORTANT methods to the enviroment
        if enviroment == nil then
            enviroment = {}
        end

        --[[
        enviroment["getCurrentProcess"] = function()
            return uuid
        end
        ]]--

        local func = funcloader(uuid, enviroment)

        local thread = spawnProcess(enviroment, function(...)
            --return run_sandbox(enviroment, func, ...)
            return func(...)
        end)
        _kernel_memory_["processes"][uuid] = {
            ["uuid"] = uuid,
            ["owner"] = owner,
            ["proxy"] = thread,
            ["data"] = {}
        }
        return uuid
    end
    function getProcessInfo(processID)
        return _kernel_memory_["processes"][processID]
    end
    function startProcess(processID, ...)
        
        return coroutine.resume(_kernel_memory_["processes"][processID]["proxy"], ...)
    end
    function killProcess(processID)
        -- TODO!
    end

--  Create IPC systems
--  [ Messaging ]
    function publishMessage(invoker, ...)
        computer.pushSignal("ipc_message", invoker, ...)
    end
    function subscribeToMessages(invoker, callback)
        table.insert(_kernel_memory_["messagesubcribers"], {
            ["invoker"] = invoker,
            ["method"] = callback
        })
    end
--  [ Pipes ]
    function createPipe(bind1, bind2)
        local uuid = generateUUID("y")
        _kernel_memory_["pipes"][uuid] = {
            ["uuid"] = uuid,
            ["binds"] = {bind1, bind2},
            ["subcriptions"] = {
                ["open"] = {function() end, function() end},
                ["close"] = {function() end, function() end},
                ["write"] = {function() end, function() end}
            }
        }
        bind1({
            ["onOpen"] = function(callback)
                _kernel_memory_["pipes"][uuid]["subcriptions"]["open"][1] = callback
            end,
            ["onClose"] = function(callback)
                _kernel_memory_["pipes"][uuid]["subcriptions"]["close"][1] = callback
            end,
            ["onWrite"] = function(callback)
                _kernel_memory_["pipes"][uuid]["subcriptions"]["write"][1] = callback
            end,
            ["close"] = function()
                computer.pushSignal("ipc_pipe_close", uuid)
            end,
            ["write"] = function(...)
                computer.pushSignal("ipc_pipe_write", uuid, 1, {...})
            end
        })
        bind2({
            ["onOpen"] = function(callback)
                _kernel_memory_["pipes"][uuid]["subcriptions"]["open"][2] = callback
            end,
            ["onClose"] = function(callback)
                _kernel_memory_["pipes"][uuid]["subcriptions"]["close"][2] = callback
            end,
            ["onWrite"] = function(callback)
                _kernel_memory_["pipes"][uuid]["subcriptions"]["write"][2] = callback
            end,
            ["close"] = function()
                computer.pushSignal("ipc_pipe_close", uuid)
            end,
            ["write"] = function(...)
                computer.pushSignal("ipc_pipe_write", uuid, 2, {...})
            end
        })

        return uuid
    end

    function _examplePipeBind_(pipe)
        pipe.onOpen(function()
            print("Pipe opened!")
        end)

        --  pipe:onWrite(callback: (...) -> Void) -> Void
        pipe.onWrite(function(...)
            -- invoked when the pipe is written to!
            local data = {...}
            print("They said " + data[1])
        end)

        --  pipe:onClose(callback: () -> Void) -> Void
        pipe.onClose(function()
            -- invoked when the pipe is closed!
        end)

        --  pipe:write(data: ...) -> Void
        pipe.write("Hello world!")

        --  pipe:close() -> Void
        pipe.close()
    end

--  [ Channels ]
    function createChannel(invoker)
        -- list types => 0: none; 1: whitelist; 2: blacklist;
        local uuid = generateUUID("c")
        _kernel_memory_["channels"][uuid] = {
            ["uuid"] = uuid,
            ["owner"] = invoker,
            ["list"] = {["type"] = 0, ["contents"] = {}},
            ["canwrite"] = {},
            ["subcribers"] = {},
            ["published-name"] = nil
        }
        return uuid
    end
    function deleteChannel(channelID)
        _kernel_memory_["channels"][channelID] = nil
    end
    function writeToChannel(invoker, channelID, ...)
        computer.pushSignal("ipc_channel_write", channelID, invoker, {...})
    end
    function grantChannelWritePermission(channelID, targetID)
        -- targetID is either the UUID of a process, user, group, or it is the literal "all"
        table.insert(_kernel_memory_["channels"][channelID]["canwrite"], targetID)
    end
    function revokeChannelWritePermission(channelID, targetID)
        -- targetID is either the UUID of a process, user, group, or it is the literal "all"
        removeFromTableByValue(_kernel_memory_["channels"][channelID]["canwrite"], targetID)
    end
    function publishChannel(channelID, channelName, target)
        -- target is either the UUID of a process, user, group, the literal "all", or nil.
        -- If the target is either "all" or nil, then the channel is available to anyone.
        -- TODO: Selective publishing. For now, all publishments are PUBLIC!
        if _kernel_memory_["published-channels"][channelName] ~= nil then
            error("Channel already exists!")
        end

        _kernel_memory_["channels"][channelID]["published-name"] = channelName
        _kernel_memory_["published-channels"][channelName] = {
            ["UUID"] = channelID,
            ["name"] = channelName,
            ["targets"] = {target},
        }
    end
    function unpublishChannel(invoker, channelID)
        -- unpublishes the channel
        local channelName = _kernel_memory_["channels"][channelID]["published-name"]
        _kernel_memory_["published-channels"][channelName] = nil
        _kernel_memory_["channels"][channelID]["published-name"] = nil
    end
    function lookupChannel(channelName)
        -- tries to find a published channel by that name, and if found returns the UUID, otherwise returns nil
        return _kernel_memory_["published-channels"][channelName]
    end
    function subcribeToChannel(channelID, callback)
        table.insert(_kernel_memory_["channels"][channelID]["subcribers"], callback)
    end

--  Create a timer system
function defineTimer(delayInSeconds, callback)
    local currentTime = os.time()
    local triggerTime = currentTime + delayInSeconds
    table.insert(_kernel_memory_["timers"], {
        ["created"] = currentTime,
        ["trigger"] = triggerTime,
        ["callback"] = callback
    })
end

--===============================[ Define Kernal Responders ]===============================--
function getDriver(type)
    --[[
        These are the drivers that we need ASAP:
            - Filesystem (ManagedFS)
            - GPU
            - Screen
            - Drive
    ]]

    local driver = _kernel_memory_["drivers"][type:lower()]

    if driver == nil then
        driver = {
            class = "generic",
            name = "generic-driver",
            new = function(proxy)
                return proxy
            end
        }
    end

    return driver

end

function createDeviceSocketFile()
    --[[
        Create a virtual folder/file at `/dev` for the device!
        This is the COMPONENT SOCKET. The driver will likely create a device socket file too!
        The DSFs created here will look like this `/dev/c--`, where the last are a UUID.
    ]]
end
function loadComponents()
    for address, componentType in component.list() do
        if _kernel_memory_["components"][address] == nil then
            local driver = getDriver(componentType)

            _kernel_memory_["components"][address] = {
                ["address"] = address,
                ["type"] = componentType,
                ["slot"] = component.slot(address),
                ["driver-class"] = driver.class,
                ["driver-name"] = driver.name,
                ["proxy"] = driver.new(component.proxy(address))
            }

            computer.pushSignal("kernel_device_connected", address)
        end
    end
end
function pollComponents()
    if #component.list() ~= #_kernel_memory_["components"] then
        -- A component was added or removed! 
        loadComponents()
    end
end

function clock_tick()
    --  Get the current time
    local currentTime = os.time()

    -- Debug!
    _kernel_memory_["data"]["display_main"].set(1, 13, "clock_tick @ " .. tostring(currentTime))

    -- Verify at least a second has passed!
    if currentTime > _kernel_memory_["os-timer-last-tick"] then
        _kernel_memory_["data"]["display_main"].set(1, 14, "clock_update @ " .. tostring(currentTime))
        --  Check if any timers have expired!
        for index, timer in pairs(_kernel_memory_["timers"]) do
            if timer["trigger"] <= currentTime then
                timer["callback"]()
                table.remove(_kernel_memory_["timers"], index)
            end
        end

        _kernel_memory_["os-timer-last-tick"] = os.time()
    end

    --  Call a method to say the clock has updated!
    computer.pushSignal("kernel_clock_tick")
    _kernel_memory_["data"]["display_main"].set(1, 15, "clock_update_return @ " .. tostring(os.time()))
end

--  Create kernel 'interrupt' method
function kernel_signal(invoker, job, ...)
    local arguments = {...}
    job = job:lower()
    if job == "get_data" then
        local pentry = _kernel_memory_["processes"][invoker]

        if pentry["data"][arguments[1]] ~= nil then
            return true, pentry["data"][arguments[1]]
        end
    elseif job == "shutdown" then
        _kernel_memory_["states"]["running"] = false
        return true
    elseif job == "reboot" then
        _kernel_memory_["states"]["running"] = false
        _kernel_memory_["states"]["reboot"] = true
        return true
    end

    return false
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
        wrap = coroutine.wrap,
        yeild = coroutine.yeild
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
        upper = string.upper 
    },
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
    },
    print = print,
    --  Custom Objects
}

--====================================[ Start OS Level ]====================================--
local clearscreen
do
    local screen = component.list("screen", true)()
    local gpu = screen and component.list("gpu", true)()

    gpu = component.proxy(gpu)

    if not gpu.getScreen() then
        gpu.bind(rawget(self, "screen"))
    end
    local w, h = gpu.maxResolution()
    gpu.setResolution(w, h)
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")
  
    local tty_lib = importfile(rfaddr, "/lib/kernel/tty.lua")
    local tty = tty_lib.new(gpu)

    _kernel_memory_["data"]["display_main"] = gpu
    _kernel_memory_["data"]["tty"] = tty

    clearscreen = function()
        local w, h = gpu.maxResolution()
        gpu.setResolution(w, h)
        gpu.setBackground(0x000000)
        gpu.setForeground(0xFFFFFF)
        gpu.fill(1, 1, w, h, " ")
    end
end

function initOS()
    _kernel_memory_["data"]["display_main"].set(1, 1, "Attempting startup!")
    local os = loadfile(rfaddr, "/boot/os.lua")
    local osProcess = createProcess("kerneluser-root", _Sandbox_G, function(UUID, env)
        env["sleep"] = function(delay)
            if delay == nil then
                delay = 1
            end
            defineTimer(delay, function()
                coroutine.resume(_kernel_memory_["processes"][env["getCurrentProcess"]()]["proxy"])
            end)    
            coroutine.yield()
        end

        env["kernsig"] = function(job, ...)
            local r = {kernel_signal(UUID, job, ...)}
            assert(r[1], "NO STATE DEFINED FOR KERNSIG")
            return table.unpack(r)
        end

        env["getCurrentProcess"] = function()
            return UUID
        end

        return loadfile(rfaddr, "/boot/os.lua", env)
    end)

    _kernel_memory_["processes"][osProcess]["data"]["display_main"] = _kernel_memory_["data"]["display_main"]
    _kernel_memory_["processes"][osProcess]["data"]["tty_main"] = _kernel_memory_["data"]["tty"]

    local results = table.pack(startProcess(osProcess, _kernel_memory_["data"]["display_main"]))

    if (results[1] == false) or ((results[2] == false)) then
        clearscreen()
        _kernel_memory_["data"]["display_main"].set(1, 1, "OS Error!")
        local y = 2
        for index, value in pairs(results) do
            if value == true then
                _kernel_memory_["data"]["display_main"].set(1, y, "true")
            elseif value == false then
                _kernel_memory_["data"]["display_main"].set(1, y, "false")
            elseif value == nil then
                _kernel_memory_["data"]["display_main"].set(1, y, "nil")
            else
                _kernel_memory_["data"]["display_main"].set(1, y, tostring(value))
            end
            y = y + 1
        end
    end
end

initOS()

--[[
    Create signal handler loop
    The loop will run so long as the system's `running` flag is set. This loop is required, otherwise the system will halt!
]]
_kernel_memory_["data"]["display_main"].set(1, 10, "Attempting kernel loop!")

local clock_thread = coroutine.create(function()
    while _kernel_memory_["states"]["running"] do
        _kernel_memory_["data"]["display_main"].set(1, 11, "clock_thread_tick @ " .. tostring(os.time()))
        clock_tick()
        _kernel_memory_["data"]["display_main"].set(1, 12, "clock_thread_tick_ok @ " .. tostring(os.time()))
    end
    _kernel_memory_["data"]["display_main"].set(1, 12, "clock_thread_close @ " .. tostring(os.time()))
end)

coroutine.resume(clock_thread)

while _kernel_memory_["states"]["running"] do
    -- computer.pushSignal("ipc_message_" .. channel, sender, ...)
    -- computer.pullSignal("ipc_message_" .. channel)
    _kernel_memory_["data"]["display_main"].set(1, 17, "os_tick @ " .. tostring(os.time()))
    computer.pullSignal(1)
end
_kernel_memory_["data"]["display_main"].set(1, 18, "os_halt @ " .. tostring(os.time()))
computer.shutdown(_kernel_memory_["states"]["reboot"])