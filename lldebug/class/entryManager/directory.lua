local PATH = (...):gsub('[^/.\\]+$', '')
local Entry = require(PATH .. 'entry')

---@class Directory
---@field entries Entry[]
local Directory = setmetatable({}, { __index = Entry })


---comment
---@param index integer
---@return Entry
function Directory:getEntryByIndex(index)
    return self.entries[index]
end


---comment
---@param name string
---@return Entry|nil
function Directory:getEntry(name)
    for _, entry in ipairs(self.entries) do
        if entry.name == name then
            return entry
        end
    end

    return nil
end


---@param name string
---@return integer
function Directory:getEntryIndex(name)
    for i, entry in ipairs(self.entries) do
        if entry.name == name then
            return i
        end
    end

    return 1
end





---comment
---@return integer
function Directory:getItemCount()
    return #self.entries
end


---comment
---@param entry Entry
function Directory:add(entry)
    entry.parent = self
    table.insert(self.entries, entry)
end


---comment
function Directory:remove()
    for i = #self.entries, 1, -1 do
        self.entries[i]:remove()
        table.remove(self.entries, i)
    end
end


---comment
---@param name string
---@return boolean
function Directory:removeEntry(name)
    for i = #self.entries, 1, -1 do
        if self.entries[i].name == name then
            self.entries[i]:remove()
            table.remove(self.entries, i)
            return true
        end
    end

    return false
end


---factory for loop process
---@return Entry[]
function Directory:getEntries()
    return self.entries
end


---comment
---@param name string
---@return Directory
function Directory.new(name)
    local obj = Entry.new(name) --[[@as Directory]]

    obj.entries = {}

    local mt = getmetatable(obj)
    mt.__index = Directory
    return setmetatable(obj, mt)
end


return Directory
