--[[
    LittleSuit Kernel
    Developed by Ethan Manzi
]]

--  Define some important information variables
_G._OSVERSION = "LittleSuit 1.0.0"
_G._KERNEL = "LittleSuit"

--  Define some important kernel variables
local bootDiskAddress = nil
local bootloaderData = nil

--  Define important kernel arrays
local components = {}
local users = {}
local processes = {}
local sockets = {}
local drivers = {}

--  Define some kernel objets
local rootFS

--  Some helper methods
function loadfile(file)
    local handle = assert(component.invoke(bootDiskAddress, "open", file))
    local buffer = ""
    repeat
      local data = component.invoke(bootDiskAddress, "read", handle, math.huge)
      buffer = buffer .. (data or "")
    until not data
    component.invoke(bootDiskAddress, "close", handle)
    return load(buffer, "=" .. file, "bt", _G)
end


--  Start the bootup!
components = component.list()
bootDiskAddress = computer.getBootAddress()

--  Now to load some core libraries
local fsrootlib = loadfile("/lib/core/fsroot.lua")() -- A library that acts as the static filesystem tracker

--  Now to load some drivers
local managedDiskDriver = loadfile("/lib/core/drivers/managedDisk.lua")()
local virtualDiskDriver = loadfile("/lib/core/drivers/virtualDisk.lua")()

--  First, we need to create a rootfs
rootFS = rootfslib.new()

--  Now mount our boot disk
rootFS:mount("/", bootDiskAddress)

--  Create a /dev for storing the handles to devices
local devfs = virtualDiskDriver.new()
rootFS:mount("/dev", devfs)
devfs:addDevice("sda", bootDiskAddress)

--  We need to sort through the components, and find any that are FILESYSTEMs
