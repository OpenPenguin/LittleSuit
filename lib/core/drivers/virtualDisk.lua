local virtualDisk = {}

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

    --  Helper Objects
    local folder = {}
        function folder.new(parent)
            return rawset({["parent"]=parent, ["children"]={}}, folder)
        end

        function folder.type()
            return "folder"
        end

        function folder.getChild(self, index)
            local children = rawget(self, "children")
            if index == nil then
                return children
            end
            return children[index]
        end

        function folder.appendChild(self, child, name)
            local children = rawget(self, "children")
            children[name] = child
            rawset(self, "children", children)
        end

        function folder.getParent(self)
            return rawget(self, "parent")
        end

        function folder.deleteChild(self, childName)
            local children = rawget(self, "children")
            children[childName] = nil
            rawset(self, "children", children)
        end

    local file = {}
        function file.new(parent)
            return rawset({["parent"]=parent, ["contents"]=""})
        end

        function file.type()
            return "file"
        end

        function file.getParent(self)
            return rawget(self, "parent")
        end

        function file.setContents(self, newContents)
            rawset(self, "contents", newContents)
        end

        function file.getContents(self)
            return rawget(self, "contents")
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

    function getEndObject(currentNode, segments, offset)
        if offset = nil then
            offset = 0
        end
        local segments = tokenisePath(path)
        for index = 1, (#segments - offset) do
            currentNode = assert(currentNode.getChild(currentNode, segments[index]), "Unable to decent node!")
        end
        return currentNode, segments
    end

    function makeHandle(self, path, writeEnabled)
        local object, segments = getEndObject(rawget(self, "objects")[1], path)
        local handle = {["path"] = path, ["buffer"] = object:getContents(), ["writeEnabled"] = writeEnabled, ["hadWritten"] = false}
        return handle
    end

    --  Module
    function virtualDisk.new()
        return setmetatable({
            ["root"] = folder.new(nil),
            ["mounts"] = {},
            ["handles"] = {},
            ["objects"] = {}
        }, virtualDisk)
    end

    function virtualDisk.mount(self, path, deviceProxy)
        local mounts = rawget(self, "mounts")
        mounts[path] = deviceProxy
        rawset(self, "mounts", mounts)
    end

    function virtualDisk.findParentOf(self, path)
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

    function virtualDisk.makeDirrectory(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject ~= nil then
            parentObject:makeDirrectory(parentObject, table.concat(relPath, "/"))
        else
            --  I am the parent!
            local tree = rawget(self, "objects")[1]
            local treeParent, segments = getEndObject(tree, path, 1)
            local newFolder = folder.new(folder, treeParent)
            treeParent:appendChild(treeParent, newFolder, segments[#segments])
            rawset(self, "objects", tree)
        end
    end

    function virtualDisk.delete(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject ~= nil then
            parentObject.delete(parentObject, table.concat(relPath, "/"))
        else
            --  I am the parent!
            local tree = rawget(self, "objects")[1]
            local treeParent, segments = getEndObject(tree, path, 1)
            treeParent:deleteChild(segments[#segments])
            rawset(self, "objects", tree)
        end
    end

    function virtualDisk.listDirrectory(self, path)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject ~= nil then
            return parentObject.listDirrectory(parentObject, table.concat(relPath, "/"))
        else
            --  I am the parent!
            local tree = rawget(self, "objects")[1]
            local treeParent, segments = getEndObject(tree, path)
            local childNodes = treeParent:getChild()
            local result = {}
            for childName, object in pairs(childNodes) do
                table.insert(result, childName)
            end
            return result
        end
    end

    function virtualDisk.openFile(self, path, mode)
        local parentObject, sharedNodes, relPath = self.findParentOf(self, path)
        if parentObject ~= nil then
            return parentObject.openFile(parentObject, table.concat(relPath, "/"), mode)
        else
            --  I am the parent!
            local handles = rawget(self, "handles")
            local writeEnabled = false
            if mode:lower() == "w" then
                writeEnabled = true
            end
            local ID = #handles
            local handle = makeHandle(self, path, writeEnabled)
            handles[ID] = handle
            rawset(self, "handles")
            return ID
        end
    end

    function virtualDisk

return virtualDisk