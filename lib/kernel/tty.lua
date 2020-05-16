local tty = {}
    tty.__metatable = tty

    tty.__index = function(self, index)
        if tty[index] ~= nil then
            return tty[index]
        end
    end

    function tty.new(display)
        local w, h = display.maxResolution()

        return setmetatable({
            ["display"] = display,
            ["x"] = 1,
            ["y"] = 1,
            ["lines"] = {},
            ["width"] = w,
            ["height"] = h
        }, tty)
    end

    function tty.clear(self)
        local gpu = rawget(self, "display")
        gpu.setBackground(0x000000)
        gpu.setForeground(0xFFFFFF)
        gpu.fill(1, 1, rawget(self, "width"), rawget(self, "height"), " ")
        rawset(self, "x", 1)
        rawset(self, "y", 1)
    end

    function tty.clearLine(self)
        rawset(self, "x", 1)
    end

    function tty.print(self, str)
        local x = rawget(self, "x")
        local y = rawget(self, "y")
        local w = rawget(self, "height")
        local h = rawget(self, "width")
        local display = rawget(self, "display")

        for i=1, string.len(str) do
            local c = str:sub(i,i)
            if c == '\n' then
                y = y + 1
                x = 1
            else
                display.set(x, y, str:sub(i,i))
                x = x + 1
            end

            if x > w then
                x = 1
                y = y + 1
            end
            -- Later, add support for scrolling!
            if y > h then
                y = 1
                x = 1
            end
        end

        rawset(self, "x", x)
        rawset(self, "y", y)
    end

    function tty.println(self, str)
        self:print(str .. "\n")
    end
    
    local keyboard = require("keyboard.lua")

    function getKeyUp()
        local _, _, char, code = events.pull("key_up")
        --return keyboard.convertKeycode(char) or ""
        --return tostring(char)
        --return tostring(code)
        local name, char = keyboard.convertKeycode(code)
        char = char or ""
        return name, char
    end

    function tty.readCharacter(self)
        local _, c = getKeyUp()
        self:print(c)
        return c
    end

return tty