local PATH = ... .. '.'
local Directory = require(PATH .. 'directory')


---@class EntryManager
---@field _root Directory rootdir
local EntryManager = {}

---comment
---@return Directory
function EntryManager:getRootDir()
    return self._root
end

---comment
---@return EntryManager
function EntryManager.new()
    local obj = {}

    obj._root = Directory.new('root')

    return setmetatable(obj, { __index = EntryManager })
end


return EntryManager
