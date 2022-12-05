---@class Director
local Director = {}

---comment
---@param signal string
---@param ... any arguments for functions
function Director:notify(signal, ...)
    for func in pairs(self[signal]) do
        func(...)
    end
end

---comment
---@param signal string
---@param func function
---@return function
function Director:register(signal, func)
    self[signal] = self[signal] or {}
    self[signal][func] = func
    return func
end

---comment
---@param signal string
---@param ... function functions to remove
function Director:remove(signal, ...)
    local funcs = { ... }
    for i = 1, #funcs do
        self[signal][funcs[i]] = nil
    end
end

---comment
---@param ... string signals to remove
function Director:clear(...)
    local signals = { ... }
    for i = 1, #signals do
        self[signals[i]] = {}
    end
end

---comment
---@return Director
function Director.new()
    local obj = {}

    return setmetatable(obj, { __index = Director })
end

return Director
