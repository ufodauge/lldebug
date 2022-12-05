--------------------------------------------------------------
-- Import
--------------------------------------------------------------
local PATH         = (...):gsub('[^/.\\]+$', '')
local EntryManager = require(PATH .. 'entrymanager')
local Directory    = require(PATH .. 'entrymanager.directory')
local Executable   = require(PATH .. 'entrymanager.executable')
local KeyManager   = require(PATH .. 'keyManager')


--------------------------------------------------------------
-- Shorthands
--------------------------------------------------------------
local lg = love.graphics


--------------------------------------------------------------
-- Utils
--------------------------------------------------------------

---@param subject any
---@param super any
local function isInstanceOf(subject, super)
    local ss = tostring(super)
    local mt = getmetatable(subject)

    while true do
        if mt == nil then
            return false
        end

        if tostring(mt.__index) == ss then
            return true
        end

        mt = getmetatable(mt.__index)
    end
end


--------------------------------------------------------------
-- Debug Menu
--------------------------------------------------------------

---@class DebugMenu
---@field display       boolean
---@field key_manager   KeyManager
---@field entry_manager EntryManager
---@field current_dir   Directory
---@field cursor_index  integer
---@field x             integer
---@field y             integer
local DebugMenu = {}


function DebugMenu:update(dt)
    self.key_manager:update(dt, { 'hide' })

    -- you can't controll menu while not displaying
    if not self.display then
        return
    end

    self.key_manager:update(dt, { 'up', 'down', 'ok' })
end


function DebugMenu:draw()
    if not self.display then
        return
    end

    local line_height = lg.getFont():getHeight()
    local entries = self.current_dir:getEntries()
    for index, entry in ipairs(entries) do

        -- For each Entries
        --------------------------------------------------------------
        local name = entry:getName()
        lg.print(
            ' ' .. name, -- add space to display cursor
            self.x,
            self.y + line_height * (index - 1))
    end

    -- print "return"
    --------------------------------------------------------------
    lg.print(
        ' return',
        self.x,
        self.y + line_height * #entries)

    -- Selecting index
    --------------------------------------------------------------
    lg.print(
        '>',
        self.x,
        self.y + line_height * (self.cursor_index - 1))
end


---return true if toggler could be added
---@param name string display name
---@param func function toggle function
---@return boolean
function DebugMenu:addToggler(name, func)
    local toggleDir = self.entry_manager
        :getRootDir()
        :getEntry('toggle') --[[@as Directory]]

    -- Check directory existence
    --------------------------------------------------------------
    if toggleDir == nil or toggleDir:getEntry(name) then
        return false
    end
    toggleDir:add(Executable.new(name, func))

    return true
end


---return true if toggler could be removed
---@param name string
---@return boolean
function DebugMenu:removeToggler(name)
    local toggleDir = self.entry_manager
        :getRootDir()
        :getEntry('toggle') --[[@as Directory]]

    if toggleDir == nil or not toggleDir:getEntry(name) then
        return false
    end
    toggleDir:removeEntry(name)

    return true
end


---comment
---@param x integer
---@param y integer
---@return DebugMenu
function DebugMenu.new(x, y)
    local obj = {} --[[@as DebugMenu]]

    -- Fields
    --------------------------------------------------------------
    obj.display = true -- display flag
    obj.x       = x or 0 -- coordinates
    obj.y       = y or 0


    -- Entry Manager
    --------------------------------------------------------------
    obj.entry_manager = EntryManager.new() -- contains root directory
    local rootDir = obj.entry_manager:getRootDir()

    -- Togglers
    rootDir:add(Directory.new('toggle'))

    -- States
    rootDir:add(Directory.new('state'))

    -- Quit
    rootDir:add(Executable.new('quit', function()
        love.event.quit()
    end))


    -- controllers
    --------------------------------------------------------------
    obj.current_dir  = rootDir
    obj.cursor_index = 1


    -- Key Manager
    --------------------------------------------------------------
    obj.key_manager = KeyManager.new()
    obj.key_manager:setKeyConfig('up', 'pageup')
    obj.key_manager:setKeyConfig('down', 'pagedown')
    obj.key_manager:setKeyConfig('ok', 'end')
    obj.key_manager:setKeyConfig('hide', 'home')

    obj.key_manager:setControll(
        'up',
        function(frame)
            if frame == 1 then

                -- Move cursor up
                --------------------------------------------------------------
                obj.cursor_index = obj.cursor_index - 1 > 0
                    and obj.cursor_index - 1
                    or obj.current_dir:getItemCount() + 1

            end
        end)
    obj.key_manager:setControll(
        'down',
        function(frame)
            if frame == 1 then

                -- Move cursor down
                --------------------------------------------------------------
                obj.cursor_index = obj.cursor_index + 1 <= obj.current_dir:getItemCount() + 1
                    and obj.cursor_index + 1
                    or 1

            end
        end)
    obj.key_manager:setControll(
        'ok',
        function(frame)
            if frame == 1 then
                -- Execute or Move Dir
                --------------------------------------------------------------
                local ent = obj.current_dir:getEntryByIndex(obj.cursor_index)
                if not ent then

                    -- Assume selected "return"
                    --------------------------------------------------------------
                    local parent = obj.current_dir:getParent() --[[@as Directory]]
                    if parent == nil then
                        -- returns to root dir
                        obj.display = false
                    else
                        -- Set cursor an index of current directory
                        local current_name = obj.current_dir:getName()
                        obj.cursor_index = parent:getEntryIndex(current_name)

                        obj.current_dir = parent
                    end


                elseif isInstanceOf(ent, Directory) then

                    -- Move Directory
                    --------------------------------------------------------------
                    obj.current_dir = ent

                    -- Set cursor top
                    --------------------------------------------------------------
                    obj.cursor_index = 1

                elseif isInstanceOf(ent, Executable) then

                    --Execute function safely
                    --------------------------------------------------------------
                    local ok, result = xpcall(function()
                        ---@diagnostic disable-next-line: undefined-field
                        return ent:execute()
                    end, function(msg)
                        print(msg)
                        return nil
                    end)

                    print(('Exec: %b'):format(ok))
                    print(result)

                else
                    error('unreachable!')
                end
            end
        end)
    obj.key_manager:setControll(
        'hide',
        function(frame)
            if frame == 1 then
                obj.display = not obj.display
            end
        end)


    return setmetatable(obj, { __index = DebugMenu })
end


--------------------------------------------------------------
-- Export
--------------------------------------------------------------
local Export = {}
local instance = nil

---get an instance
---@return DebugMenu
function Export.getInstance()
    if instance == nil then
        instance = DebugMenu.new(5, 5)
    end

    return instance
end


return Export
