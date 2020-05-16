--[[

    This is an important wrapper!
    Since the application-level can't monitor events themselves!

]]

local io = {}

    local events = require("events")
    local keyboard = require("keyboard")

    local characters = {
        [0x02] = "1",
        [0x03] = "2",
        [0x04] = "3",
        [0x05] = "4",
        [0x06] = "5",
        [0x07] = "6",
        [0x08] = "7",
        [0x09] = "8",
        [0x0A] = "9",
        [0x0B] = "0",
        [0x1E] = "a",
        [0x30] = "b",
        [0x2E] = "c",
        [0x20] = "d",
        [0x12] = "e",
        [0x21] = "f",
        [0x22] = "g",
        [0x23] = "h",
        [0x17] = "i",
        [0x24] = "j",
        [0x25] = "k",
        [0x26] = "l",
        [0x32] = "m",
        [0x31] = "n",
        [0x18] = "o",
        [0x19] = "p",
        [0x10] = "q",
        [0x13] = "r",
        [0x1F] = "s",
        [0x14] = "t",
        [0x16] = "u",
        [0x2F] = "v",
        [0x11] = "w",
        [0x2D] = "x",
        [0x15] = "y",
        [0x2C] = "z",
        [0x28] = "'",
        [0x91] = "@",
        [0x0E] = "", -- backspace
        [0x2B] = "",
        [0x3A] = "", -- capslock
        [0x92] = ":",
        [0x33] = ",",
        [0x1C] = "\n",
        [0x0D] = "=",
        [0x29] = "~", -- accent grave
        [0x1A] = "[",
        [0x1D] = "",
        [0x38] = "", -- left Alt
        [0x2A] = "",
        [0x0C] = "-",
        [0x45] = "",
        [0xC5] = "",
        [0x34] = ".",
        [0x1B] = "]",
        [0x9D] = "",
        [0xB8] = "", -- right Alt
        [0x36] = "",
        [0x46] = "", -- Scroll Lock
        [0x27] = ";",
        [0x35] = "/", -- / on main keyboard
        [0x39] = " ",
        [0x95] = "",
        [0x0F] = "\t",
        [0x93] = "_",
        [0xC8] = "",
        [0xD0] = "",
        [0xCB] = "",
        [0xCD] = "",
        [0xC7] = "",
        [0xCF] = "",
        [0xC9] = "",
        [0xD1] = "",
        [0xD2] = "",
        [0xD3] = "",
        [0x3B] = "",
        [0x3C] = "",
        [0x3D] = "",
        [0x3E] = "",
        [0x3F] = "",
        [0x40] = "",
        [0x41] = "",
        [0x42] = "",
        [0x43] = "",
        [0x44] = "",
        [0x57] = "",
        [0x58] = "",
        [0x64] = "",
        [0x65] = "",
        [0x66] = "",
        [0x67] = "",
        [0x68] = "",
        [0x69] = "",
        [0x71] = "",
        [0x70] = "",
        [0x94] = "",
        [0x79] = "",
        [0x7B] = "",
        [0x7D] = "",
        [0x90] = "",
        [0x96] = "",
        [0x52] = "0",
        [0x4F] = "1",
        [0x50] = "2",
        [0x51] = "3",
        [0x4B] = "4",
        [0x4C] = "5",
        [0x4D] = "6",
        [0x47] = "7",
        [0x48] = "8",
        [0x49] = "9",
        [0x37] = "*",
        [0xB5] = "/",
        [0x4A] = "-",
        [0x4E] = "+",
        [0x53] = ".",
        [0xB3] = ",",
        [0x9C] = "\n",
        [0x8D] = "="
    }

    function io.readChar()
        local _, addr, char, code, playername = events.pull("key_up")
        return characters[code], code
    end

return io