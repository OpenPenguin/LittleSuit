--[[
    The FSController library.
    Manages things like mounting and virtual files
]]

local fsc = {}
    fsc.__metatable = fsc

    function fsc.new()
        return setmetatable({
            ["mounts"] = {},
            ["virtual-files"] = {}
        }, fsc)
    end

    function fsc.mount(path, driver)
        
    end

    function fsc.unmount(path)

    end

    function fsc.createVirtualFile(path, driver)

    end

    function fsc.deleteVirtualFile(path)

    end

return fsc