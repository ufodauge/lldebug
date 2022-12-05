local LLDebug = require('lldebug'):getInstance()

function love.load()
    LLDebug:activate()
end


function love.update(dt)
    LLDebug:update(dt)
end


function love.draw()
    LLDebug:draw()
end
