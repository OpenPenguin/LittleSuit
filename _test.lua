function badcode()
    print("I said frick! Frick is a bad word!")
    return 90210
end

local e=_ENV

sample_sandbox = {
    ["print"] = function(...)
        e.print("They tried printing!!")
        --print("THEY TRIED TO PRINT DUDE")
    end
}

function run_sandbox(sb_env, sb_func, ...)
    local sb_orig_env=_ENV
    if (not sb_func) then return nil end
    _ENV=sb_env
    local sb_ret={e.pcall(sb_func, ...)}
    _ENV=sb_orig_env
    return e.table.unpack(sb_ret)
end

print("Running sandbox...")
local pcall_rc, result_or_err_msg = run_sandbox(sample_sandbox, badcode)
print(result_or_err_msg)
print("Sandbox ran!")