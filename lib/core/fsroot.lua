local rootfs = {}

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
    function rootfs.new()
        return setmetatable({
            ["mounts"] = {},
            ["handles"] = {}
        }, rootfs)
    end

    function rootfs.mount(self, path, deviceProxy)
        local mounts = rawget(self, "mounts")
        mounts[path] = deviceProxy
        rawset(self, "mounts", mounts)
    end

    function rootfs.findParentOf(self, path)
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

    function rootfs.makeDirrectory(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject == nil then
            error("No possible parent found!")
        end
        parentObject.makeDirrectory(parentObject, table.concat(relPath, "/"))
    end

    function rootfs.delete(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject == nil then
            error("No possible parent found!")
        end
        parentObject.delete(parentObject, table.concat(relPath, "/"))
    end

    function rootfs.listDirrectory(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject == nil then
            error("No possible parent found!")
        end
        parentObject.listDirrectory(parentObject, table.concat(relPath, "/"))
    end

    function rootfs.openFile(self, path, mode)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject == nil then
            error("No possible parent found!")
        end
        local handle = parentObject.openFile(parentObject, table.concat(relPath, "/"), mode)
        --  TODO: Convert this into a FileObject!
        return handle
    end

    function rootfs

return rootfs