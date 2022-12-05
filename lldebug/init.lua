--------------------------------------------------------------
-- const
--------------------------------------------------------------
local PATH    = ... .. '.'
local SYSPATH = PATH:gsub('%.', '/')


--------------------------------------------------------------
-- shorthands
--------------------------------------------------------------
local lg = love.graphics
local lf = love.filesystem


--------------------------------------------------------------
-- libraries
--------------------------------------------------------------
local utils           = require(PATH .. 'lib.utils')
local PeformenceGraph = require(PATH .. 'lib.peformenceGraph')


--------------------------------------------------------------
-- systems
--------------------------------------------------------------
local font_debug = utils.imageFontLoader(SYSPATH .. 'res/font')


--------------------------------------------------------------
-- Class
--------------------------------------------------------------
local Director    = require(PATH .. 'class.director')
local DebugMenu   = require(PATH .. 'class.debugMenu')
local MessageArea = require(PATH .. 'class.messageArea')


--------------------------------------------------------------
-- LLDebug
--------------------------------------------------------------

---@class LLDebug
---@field active       boolean true if LLDebug is active
---@field graph_mem    DebugGraph
---@field graph_fps    DebugGraph
---@field debug_menu   DebugMenu
---@field message_area MessageArea
local LLDebug = {}


---comment
function LLDebug:activate()
    self.active = true
end


---comment
---@param dt number
function LLDebug:update(dt)
    -- Activated Guard
    --------------------------------------------------------------
    if not self.active then
        return
    end


    -- Debug Menu
    --------------------------------------------------------------
    self.debug_menu:update(dt)


    -- Debug Graph
    --------------------------------------------------------------
    self.graph_mem:update(dt)
    self.graph_fps:update(dt)
end


---comment
function LLDebug:draw()
    -- Activated Guard
    --------------------------------------------------------------
    if not self.active then
        return
    end


    -- Render LLDebug
    --------------------------------------------------------------
    lg.setColor(1, 1, 1, 1)
    lg.setFont(font_debug)


    -- Debug Menu
    --------------------------------------------------------------
    self.debug_menu:draw()


    -- Message area
    --------------------------------------------------------------
    self.message_area:draw()


    -- Debug Graph
    --------------------------------------------------------------
    self.graph_mem:draw()
    self.graph_fps:draw()
end


---comment
---@param message string|function
function LLDebug:log(message)
    self.message_area:printMessage(message)
end


---comment
---@return LLDebug
function LLDebug.new()
    local obj = {}


    obj.active = false -- activate flag


    -- Director
    --------------------------------------------------------------
    obj.director = Director.new() --[[@as Director]]


    -- Debug Menu
    --------------------------------------------------------------
    obj.debug_menu = DebugMenu:getInstance() --[[@as DebugMenu]]


    -- Debug Graph
    --------------------------------------------------------------
    obj.graph_mem        = PeformenceGraph:new('mem')
    obj.graph_mem.width  = 160
    obj.graph_mem.height = 40
    obj.graph_mem.x      = 0
    obj.graph_mem.y      = lg.getHeight() - obj.graph_mem.height * 2
    obj.graph_mem.font   = font_debug

    obj.graph_fps        = PeformenceGraph:new('fps')
    obj.graph_fps.width  = 160
    obj.graph_fps.height = 40
    obj.graph_fps.x      = 0
    obj.graph_fps.y      = lg.getHeight() - obj.graph_fps.height
    obj.graph_fps.font   = font_debug

    ---@diagnostic disable-next-line: unused-local
    obj.director:register('resize', function(width, height)
        obj.graph_mem.x = 0
        obj.graph_mem.y = height - obj.graph_mem.height * 2

        obj.graph_fps.x = 0
        obj.graph_fps.y = height - obj.graph_fps.height
    end)


    -- Display area for debug message
    --------------------------------------------------------------
    obj.message_area = MessageArea.new() --[[@as MessageArea]]
    obj.message_area.w = 300
    obj.message_area.h = 120
    obj.message_area.x = lg.getWidth() - obj.message_area.w
    obj.message_area.y = lg.getHeight() - obj.message_area.h

    ---@diagnostic disable-next-line: unused-local
    obj.director:register('resize', function(width, height)
        obj.message_area.x = width - obj.message_area.w
        obj.message_area.y = height - obj.message_area.h
    end)


    -- On Window Resize Callback
    --------------------------------------------------------------
    local _resize = love.resize or function() end
    function love.resize(width, height)
        _resize(width, height)
        obj.director:notify('resize', width, height)
    end


    return setmetatable(obj, { __index = LLDebug })
end


--------------------------------------------------------------
-- Export
--------------------------------------------------------------
local Export = {}
local instance = nil


---get an instance
---@return LLDebug
function Export:getInstance()
    if instance == nil then
        instance = LLDebug.new()
    end

    return instance
end


return Export
