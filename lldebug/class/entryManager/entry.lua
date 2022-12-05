---@class Entry
---@field name string entry's name
---@field parent Directory directory that contains myself
---@field dead boolean treu if removed
local Entry = {}


---@return string name
function Entry:getName()
    return self.name
end


---obsolated
function Entry:remove()
    self.dead = true
end


---comment
function Entry:getParent()
    return self.parent
end


---comment
---@param class any
function Entry:isInctanceOf(class)
    return tostring(self) == tostring(class)
end


---comment
---@param name string
---@return Entry
function Entry.new(name)
    local obj = {} --[[@as Entry]]

    assert(name, "Entry name is unset")

    obj.name = name
    obj.parent = nil

    setmetatable(obj, {
         __index = Entry
    })

    return obj
end


return Entry
