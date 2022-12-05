--------------------------------------------------------------
-- const
--------------------------------------------------------------
local MAX_MESSAGE_LOG = 40
local GAIN_OPACUE_LINES = 4


--------------------------------------------------------------
-- Shorthands
--------------------------------------------------------------
local lg = love.graphics


--------------------------------------------------------------
-- MessageArea
--------------------------------------------------------------

---@class MessageArea
---@field message_log (string|function)[]
---@field x integer
---@field y integer
---@field w integer
---@field h integer
local MessageArea = {}


---enqueue message and dequeue old info
---@param message string|function
function MessageArea:printMessage(message)
    table.insert(self.message_log, 1, message)
    if #self.message_log > MAX_MESSAGE_LOG then
        self.message_log = { unpack(self.message_log, 1, MAX_MESSAGE_LOG) }
    end
end


function MessageArea:draw()
    local x, y, w, h = self.x, self.y, self.w, self.h

    local font_height = lg.getFont():getHeight()
    local r, g, b, a = lg.getColor()

    for i = 1, #self.message_log do
        local mes = self.message_log[i]

        -- Transparent over-height messages
        --------------------------------------------------------------
        a = h - font_height * i < 0
            and 0
            or a

        a = h - font_height * (i + GAIN_OPACUE_LINES) < 0
            and a * 0.75
            or a

        if type(mes) == 'function' then
            local ok, res = xpcall(
                function()
                    return tostring(mes())
                end,
                function(mes)
                    return mes
                end)
            mes = res
        end

        lg.setColor(r, g, b, a)
        lg.print(('%d: %s'):format(i, mes), x, y + h - font_height * i)
    end

    lg.setColor(r, g, b, 1)
end


---comment
---@return MessageArea
function MessageArea.new()
    local obj = {}

    obj.message_log = {}

    obj.x = 600
    obj.y = 300
    obj.w = 200
    obj.h = 300

    return setmetatable(obj, { __index = MessageArea })
end


return MessageArea
