function badcode()
    print("I said frick! Frick is a bad word!")
end

local e=_ENV

function run_sandbox(sb_env, sb_func, ...)
    local sb_orig_env=_ENV
    if (not sb_func) then return nil end
    _ENV=sb_env
    local sb_ret={e.pcall(sb_func, ...)}
    _ENV=sb_orig_env
    return e.table.unpack(sb_ret)
end

run_sandbox({
    ["print"] = function(...)
        print("THEY TRIED TO PRINT DUDE")
    end
}, badcode)