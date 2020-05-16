local events = {}

    function events.pull(event_name, timeout)
        local result
        while result == nil do
            local signal = {computer.pullSignal(timeout or math.max)}
            if signal[1] == event_name then
                result = signal
            end
        end
        return table.unpack(result)
    end

return events