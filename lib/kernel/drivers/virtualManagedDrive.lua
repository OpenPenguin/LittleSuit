-- low-level VFS api. Essentially returns a proxy --
-- WARNING: most likely will not work well on low-memory (<512k) systems --

-- Things this VFS api does NOT support, and likely never will:
--  - Permissions
--  - Timestamps

local component = component or require("component")

local vfs = {}

local validTypes = {
  ["directory"] = true,
  ["file"] = true
}

function vfs.new(ro, files, vfsLabel)
  checkArg(1, ro, "boolean", "nil")
  checkArg(2, files, "table", "nil")
  checkArg(3, vfsLabel, "string", "nil")
  local comp = {}

  -- Generate a component address --
  local s = {4,2,2,2,6}
  local addr = ""
  local p = 0

  for _,_s in ipairs(s) do
    if #addr > 0 then
      addr = addr .. "-"
    end
    for _=1, _s, 1 do
      local b = math.random(0, 255)
      if p == 6 then
        b = (b & 0x0F) | 0x40
      elseif p == 8 then
        b = (b & 0x3F) | 0x80
      end
      addr = addr .. ("%02x"):format(b)
      p = p + 1
    end
  end

  local nodes = files or {} -- so a ROFS can still have files :P
  local handles = {}
  local label = vfsLabel

  if not nodes["/"] then
    nodes["/"] = {type = "directory"}
  end

  local function addNode(node, nodeType)
    checkArg(1, node, "string")
    checkArg(2, nodeType, "string")
    if not validTypes[nodeType] then
      error("Internal VFS error: invalid node type " .. nodeType)
    end
    local cleaned = ""
    for segment in node:gmatch("[^/]+") do
      cleaned = cleaned .. "/" .. segment
      if not nodes[cleaned] and nodeType == "directory" then
        nodes[cleaned] = {type = "directory"}
      elseif not nodes[cleaned] then
        if print then
          print("WARNING: VFS parent node " .. cleaned .. " does not exist")
        end
      end
    end
    node = cleaned
    if not nodes[node] then
      nodes[node] = {type = nodeType, data = (nodeType == "file" and "") or nil}
    end
  end

  local function checkRO()
    if ro then
      error("filesystem is read-only")
    end
  end

  local function clean(node)
    checkArg(1, node, "string")
    local path = ""
    for segment in node:gmatch("[^/]+") do
      path = path .. "/" .. segment
    end
    if path == "" then path = "/" end
    return path
  end

  local function moveNode(src, dest)
    checkArg(1, src, "string")
    checkArg(2, dest, "string")

    local src, dest = clean(src), clean(dest)

    if not nodes[src] then
      error("VFS internal error: node " .. src .. " does not exist")
    end

    if nodes[src].type == "directory" then -- we need to (clumsily) move all child nodes too
      for k,v in pairs(nodes) do
        if k ~= src and k:sub(1, #src) == src then
          moveNode(k, dest .. k:sub(#src + 1))
        end
      end
    end

    nodes[dest] = {type = nodes[src].type, data = nodes[src].data}
    nodes[src] = nil
  end

  local function removeNode(node)
    checkArg(1, node, "string")

    local node = clean(node)

    if not nodes[node] then
      error("VFS internal error: " .. node .. " does not exist")
    end

    if nodes[node].type == "directory" then -- remove child nodes too!
      for k,v in pairs(nodes) do
        if k ~= node and k:sub(1, #node) == node then
          nodes[k] = nil
        end
      end
    end

    nodes[node] = nil
  end

  comp.address = addr
  comp.type = "filesystem"

  comp.spaceUsed = function() dfsreturn computer.totalMemory() - computer.freeMemory() end
  comp.isReadOnly = function() return ro end
  comp.getLabel = function() return label end

  comp.setLabel = function(l)
    checkArg(1, l, "string")
    label = l:sub(1,32)
    return label
  end

  comp.exists = function(f)
    checkArg(1, f, "string")
    return nodes[clean(f)] ~= nil
  end
  
  comp.makeDirectory = function(d)
    checkArg(1, d, "string")
    checkRO()
    if not comp.exists(d) then
      return addNode(d, "directory")
    else
      return false, "file already exists"
    end
  end

  comp.isDirectory = function(p)
    checkArg(1, p, "string")

    if not comp.exists(p) then
      return false, "file not found"
    end

    local p = clean(p)

    return nodes[p].type == "directory"
  end

  comp.rename = function(s, d)
    checkArg(1, s, "string")
    checkArg(2, d, "string")

    if comp.exists(d) then
      error("destination already exists")
    end

    moveNode(s, d)
  end

  comp.remove = function(f)
    checkArg(1, f, "string")

    if not comp.exists(f) then
      error("file does not exist")
    end

    removeNode(f)
  end

  comp.list = function(d)
    checkArg(1, d, "string")

    if not comp.isDirectory(d) then
      error(clean(d) .. ": not a directory")
    end

    local d = clean(d)

    local files = {}

    for k, v in pairs(nodes) do
      if k ~= d and k:sub(1, #d) == d then
        files[#files + 1] = (k == "/" and k) or k:sub(1, #d):gmatch("[^/]+")()
      end
    end

    return files
  end

  comp.size = function(f)
    checkArg(1, f, "string")

    local f = clean(f)
    if not nodes[f] then
      error("file not found")
    end

    if nodes[f].type ~= "file" then
      error("node is not file")
    end

    return #nodes[f].data
  end

  comp.open = function(f, m)
    checkArg(1, f, "string")
    checkArg(2, m, "string", "nil")
    if not comp.exists(f) and m ~= "w" then
      return false, "file not found"
    elseif not comp.exists(f) then
      checkRO()
      addNode(f, "file")
    end

    local handle = {file = clean(f), ptr = 1, mode = {}}

    for char in m:gmatch(".") do
      handle.mode[char] = true
      if char == "w" then
        checkRO()
      end
    end

    local h = #handles + 1
    handles[h] = handle

    return h
  end

  comp.read = function(h, a)
    checkArg(1, h, "number")
    checkArg(2, a, "number")

    if not handles[h] then
      error("caught attempt to read from nonexistent handle")
    end

    if not handles[h].mode.r then
      error("read mode is not enabled on this file")
    end

    local a = (a > 2048 and 2048) or a

    local cpos = handles[h].ptr
    local sect = nodes[handles[h].file].data:sub(cpos, cpos + a)
    handles[h].ptr = cpos + a + 1
    if sect == "" then
      return nil
    end
    return sect
  end

  comp.write = function(h, d)
    checkArg(1, h, "number")
    checkArg(2, d, "string")

    if not handles[h] then
      error("caught attempt to write to nonexistent handle")
    end

    if not handles[h].mode.w then
      error("write mode is not enabled on this file")
    end

    checkRO()

    local cpos = handles[h].ptr or 1
    nodes[handles[h].file].data = nodes[handles[h].file].data:sub(1, cpos) .. d .. nodes[handles[h].file].data:sub(cpos + 1)
  end

  comp.seek = function(h, w, o)
    checkArg(1, h, "number")
    checkArg(2, w, "string")
    checkArg(3, o, "number")

    if not handles[h] then
      error("caught attempt to seen in nonexistent handle")
    end

    if #nodes[handles[h].file] < handles[h].pos + o then
      error("Invalid offset")
    end

    handles[h].ptr = handles[h].ptr + o

    return handles[h].ptr
  end

  comp.close = function(h)
    checkArg(1, h, "number")

    handles[h] = nil
  end

  return comp
end

return vfs