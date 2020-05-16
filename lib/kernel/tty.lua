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

    function tty.backspace(self)
        local x = rawget(self, "x")
        local y = rawget(self, "y")
        local display = rawget(self, "display")
        x = x - 1
        display.set(x, y, " ")
        rawset(self, "x", x)
        rawset(self, "y", y)
    end

    function tty.clearLine(self)
        rawset(self, "x", 1)
    end

    function tty.set(self, char)
        local x = rawget(self, "x")
        local y = rawget(self, "y")
        local display = rawget(self, "display")
        display.set(x, y, char)
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
    local io = require("io")

    function tty.getCharacter(self)
        return io.readChar()
    end

    function tty.readCharacter(self)
        local char, code = io.readChar()
        self:print(char)
        return char, code
    end

    function tty.readLine(self)
        local buffer = ""
        local char = ''
        local code = 0
        while not ((code == 0x1C) or (code == 0x9C)) do
            char, code = io.readChar()
            if code == 0x0E then
                self:backspace()
                if string.len(buffer) > 0 then
                    buffer = buffer:sub(1, string.len(buffer) - 1)
                end
            elseif ((code == 0x1C) or (code == 0x9C)) then
                -- EOL!
            else
                self:print(char)
                buffer = buffer .. char
            end
        end
        return buffer
    end

return tty