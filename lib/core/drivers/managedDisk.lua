local managedDisk = {}

    --  Helpers
    function tokenisePath(path)
        local segments = {}
        local buffer = ""
        local senclosed = false
        local senclosedchar = ""
        local backslashed = false

        for index = 1, path:len() do
            local char = path:sub(index, index)
            buffer = buffer .. char

            local function push()
                if buffer:len() > 0 then
                    table.insert(segments, buffer:sub(1, buffer:len() - 1))
                end
                buffer = ""
            end

            if (char = "'") or (char == '"') then
                if senclosed and (char == senclosedchar) then
                    senclosed = false
                    push()
                elseif not senclosed then
                    buffer = buffer:sub(1, buffer:len() - 1)
                    senclosed = true
                    senclosedchar = char
                end
            elseif backslashed then
                backslashed = false
            elseif char == "\\" then
                buffer = buffer:sub(1, buffer:len() - 1)
                backslashed = true
            elseif (not senclosed) and (char == "/") then
                push()
            end
        end

        push()
        return segments
    end

    function checkIfChildOf(parentPath, childPath)
        local shared, childExtra = {}, {}
        for count, node in pairs(childPath) do
            if count > #parentPath then
                -- Child is already longer
                table.insert(childExtra, node)
            elseif node == parentPath[count] then
                -- They are shared!
                table.insert(shared, node)
            else
                return false    -- They aren't shared!
            end
        end
        return true, shared, childExtra
    end

    --  Module
    function managedDisk.new(deviceProxy)
        return setmetatable({
            ["device"] = deviceProxy,
            ["mounts"] = {},
            ["handles"] = {}
        }, managedDisk)
    end

    function managedDisk.mount(self, path, deviceProxy)
        local mounts = rawget(self, "mounts")
        mounts[path] = deviceProxy
        rawset(self, "mounts", mounts)
    end

    function managedDisk.findParentOf(self, path)
        local parent = nil
        local psegs = tokenisePath(path)
        for mountPath, parentObject in pairs(rawget(self, "mounts")) do
            local isChild, sharedNodes, relPath = checkIfChildOf(tokenisePath(mountPath), psegg)
            if isChild then
                return parentObject, sharedNodes, relPath
            end
        end
        return nil
    end

    function managedDisk.makeDirrectory(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject ~= nil then
            parentObject.makeDirrectory(parentObject, table.concat(relPath, "/"))
        else
            --  I am the parent!
            component.invoke(rawget(self, "device"), "makeDirectory", path)
        end
    end

    function managedDisk.delete(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject ~= nil then
            parentObject.delete(parentObject, table.concat(relPath, "/"))
        else
            --  I am the parent!
            component.invoke(rawget(self, "device"), "remove", path)
        end
    end

    function managedDisk.listDirrectory(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject ~= nil then
            return parentObject.listDirrectory(parentObject, table.concat(relPath, "/"))
        else
            --  I am the parent!
            return component.invoke(rawget(self, "device"), "list", path)
        end
    end

    function managedDisk.openFile(self, path, mode)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject ~= nil then
            return parentObject.openFile(parentObject, table.concat(relPath, "/"), mode)
        else
            --  I am the parent!
            return component.invoke(rawget(self, "device"), "open", path, mode)
        end
    end

    function managedDisk

return managedDisk