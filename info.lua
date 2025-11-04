-- Info.lua
-- Displays debug information: FPS, delta time, and mouse position.
-- Used for internal testing and performance tracking.
local Info = {}

function Info.getDetail()
    local mx, my = love.mouse.getPosition()
    local fps = love.timer.getFPS()
    local dt = love.timer.getDelta()
    local textDt = string.format("%.4f ms", dt * 1000)
    local textFps = string.format("%i ms", fps)
    love.graphics.printf(textDt, 900, 10, 200)
    love.graphics.printf(textFps, 900, 20, 200)
    love.graphics.printf(mx .. "," .. my, 900, 30, 200)
end

return Info
