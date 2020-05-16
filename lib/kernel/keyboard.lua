local keyboard = {}
    keyboard.keys = {
        ["1"]           = 0x02,
        ["2"]           = 0x03,
        ["3"]           = 0x04,
        ["4"]           = 0x05,
        ["5"]           = 0x06,
        ["6"]           = 0x07,
        ["7"]           = 0x08,
        ["8"]           = 0x09,
        ["9"]           = 0x0A,
        ["0"]           = 0x0B,
        a               = 0x1E,
        b               = 0x30,
        c               = 0x2E,
        d               = 0x20,
        e               = 0x12,
        f               = 0x21,
        g               = 0x22,
        h               = 0x23,
        i               = 0x17,
        j               = 0x24,
        k               = 0x25,
        l               = 0x26,
        m               = 0x32,
        n               = 0x31,
        o               = 0x18,
        p               = 0x19,
        q               = 0x10,
        r               = 0x13,
        s               = 0x1F,
        t               = 0x14,
        u               = 0x16,
        v               = 0x2F,
        w               = 0x11,
        x               = 0x2D,
        y               = 0x15,
        z               = 0x2C,
        apostrophe      = 0x28,
        at              = 0x91,
        back            = 0x0E, -- backspace
        backslash       = 0x2B,
        capital         = 0x3A, -- capslock
        colon           = 0x92,
        comma           = 0x33,
        enter           = 0x1C,
        equals          = 0x0D,
        grave           = 0x29, -- accent grave
        lbracket        = 0x1A,
        lcontrol        = 0x1D,
        lmenu           = 0x38, -- left Alt
        lshift          = 0x2A,
        minus           = 0x0C,
        numlock         = 0x45,
        pause           = 0xC5,
        period          = 0x34,
        rbracket        = 0x1B,
        rcontrol        = 0x9D,
        rmenu           = 0xB8, -- right Alt
        rshift          = 0x36,
        scroll          = 0x46, -- Scroll Lock
        semicolon       = 0x27,
        slash           = 0x35, -- / on main keyboard
        space           = 0x39,
        stop            = 0x95,
        tab             = 0x0F,
        underline       = 0x93,
        up              = 0xC8,
        down            = 0xD0,
        left            = 0xCB,
        right           = 0xCD,
        home            = 0xC7,
        ["end"]         = 0xCF,
        pageUp          = 0xC9,
        pageDown        = 0xD1,
        insert          = 0xD2,
        delete          = 0xD3,
        f1              = 0x3B,
        f2              = 0x3C,
        f3              = 0x3D,
        f4              = 0x3E,
        f5              = 0x3F,
        f6              = 0x40,
        f7              = 0x41,
        f8              = 0x42,
        f9              = 0x43,
        f10             = 0x44,
        f11             = 0x57,
        f12             = 0x58,
        f13             = 0x64,
        f14             = 0x65,
        f15             = 0x66,
        f16             = 0x67,
        f17             = 0x68,
        f18             = 0x69,
        f19             = 0x71,
        kana            = 0x70,
        kanji           = 0x94,
        convert         = 0x79,
        noconvert       = 0x7B,
        yen             = 0x7D,
        circumflex      = 0x90,
        ax              = 0x96,
        numpad0         = 0x52,
        numpad1         = 0x4F,
        numpad2         = 0x50,
        numpad3         = 0x51,
        numpad4         = 0x4B,
        numpad5         = 0x4C,
        numpad6         = 0x4D,
        numpad7         = 0x47,
        numpad8         = 0x48,
        numpad9         = 0x49,
        numpadmul       = 0x37,
        numpaddiv       = 0xB5,
        numpadsub       = 0x4A,
        numpadadd       = 0x4E,
        numpaddecimal   = 0x53,
        numpadcomma     = 0xB3,
        numpadenter     = 0x9C,
        numpadequals    = 0x8D
    }

    keyboard.chars = {
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

    function keyboard.convertKeycode(keycode)
        for name, code in pairs(keyboard.keys) do
            if code == keycode then
                return name, keyboard.chars[code]
            end
        end
        return nil, ''
    end

return keyboard