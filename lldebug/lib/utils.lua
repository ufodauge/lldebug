-- shorthands
local lg = love.graphics
local lf = love.filesystem

local util = {}


---load file safely
---@param filename string
---@return any
---@return string?
util.fileLoader = function(filename)
    local loaded, chunk, err = pcall(lf.load, filename) -- load the chunk safely

    if not loaded then
        return false, 'Failed loading code: ' .. chunk
    end
    if not chunk then
        return false, 'Failed reading file: ' .. err
    end

    local executed, value = pcall(chunk) -- execute the chunk safely
    if not executed then
        return false, 'Failed calling chunk: ' .. tostring(value)
    end

    return value
end


---load font safely
---@param filename string
---@return love.Font
util.imageFontLoader = function(filename)
    local glyphs, errmsg = util.fileLoader(filename .. '.lua') --[[@as string]]
    if errmsg then
        print(errmsg)
        return lg.getFont()
    end

    local font = lg.newImageFont(filename .. '.png', glyphs)
    font:setFilter('nearest', 'nearest')

    return font
end


return util
