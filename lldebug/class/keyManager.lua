local MAX_KEYPRESS_FRAME = 256


---comment
---@generic T
---@param arr T[]
---@param sbj T
---@return boolean
local function contains(arr, sbj)
    for i = 1, #arr do
        if arr[i] == sbj then
            return true
        end
    end
    return false
end


---@class KeyManager
---@field key_conf string[]
---@field key_controll function[]
---@field key_frame integer[]
local KeyManager = {}

---comment
---@param act_name string
---@param keys string
function KeyManager:setKeyConfig(act_name, keys)
    self.key_conf[act_name] = keys
    self.key_frame[act_name] = 0
end


---comment
---@param act_name string
---@param action function
function KeyManager:setControll(act_name, action)
    self.key_controll[act_name] = action
end


---comment
---@param dt integer
---@param controll_tags string[]
function KeyManager:update(dt, controll_tags)
    for act_name, action in pairs(self.key_controll) do

        if (controll_tags and contains(controll_tags, act_name))
            or not controll_tags then

            if love.keyboard.isDown(self.key_conf[act_name]) then
                self.key_frame[act_name] = self.key_frame[act_name] + 1 < MAX_KEYPRESS_FRAME
                    and self.key_frame[act_name] + 1
                    or self.key_frame[act_name]
            else
                self.key_frame[act_name] = 0
            end

            action(self.key_frame[act_name])
        end

    end
end


---comment
---@return KeyManager
function KeyManager.new()
    local obj = {}

    obj.key_conf = {}
    obj.key_controll = {}
    obj.key_frame = {}

    setmetatable(obj, { __index = KeyManager })

    return obj
end


return KeyManager
