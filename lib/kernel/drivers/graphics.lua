local gpu_driver = {}

    gpu_driver.__metatable = gpu_driver

    gpu_driver.__index = function(self, index)
        if gpu_driver[index] ~= then
            return gpu_driver[index]
        end

        if index == "width" then
            return rawget(self, "width") or -1
        elseif index == "height" then
            return rawget(self, "height") or -1
        end

        if rawget(self, "gpu") ~= nil then
            if rawget(self, "gpu")[index] ~= nil then
                return rawget(self, "gpu")[index]
            end
        end
        
    end

    function gpu_driver.new(gpu, screen)
        return setmetatable({
            ["gpu"] = gpu,
            ["screen"] = screen,
            ["width"] = -1,
            ["height"] = -1,
        }, gpu_driver)
    end

    function gpu_driver.init(self)
        local gpu = rawget(self, "gpu")
        if not gpu.getScreen() then
            gpu.bind(rawget(self, "screen"))
        end
        local w, h = gpu.maxResolution()
        gpu.setResolution(w, h)
        gpu.setBackground(0x000000)
        gpu.setForeground(0xFFFFFF)
        gpu.fill(1, 1, w, h, " ")
        rawset(self, "width", w)
        rawset(self, "height", h)
    end

    function gpu_driver.clear(self)
        local gpu = rawget(self, "gpu")
        gpu.setBackground(0x000000)
        gpu.setForeground(0xFFFFFF)
        gpu.fill(1, 1, self.width, self.height, " ")
    end

return gpu_driver