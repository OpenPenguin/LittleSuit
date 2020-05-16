--[[
    GenericDriver

    Mostly a placeholder, to show the minimum required methods available via a driver.
]]

local gdriver = {}

    --  "Static Methods"
    function gdriver.setDriverInfo()
        return {
            ["class"] = "generic",
            ["type"] = "generic"
        }
    end

    --  Constructor(s)
    function gdriver.new()
        return setmetatable({}, gdriver)
    end

    --  Object Methods

return gdriver