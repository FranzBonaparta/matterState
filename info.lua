local Info = {}

function Info.getDetail()
    local mx, my = love.mouse.getPosition()
    local fps = love.timer.getFPS()
    local dt = love.timer.getDelta()
    local textDt = string.format("%.4f ms", dt * 1000)
    local textFps = string.format("%i ms", fps)
    love.graphics.printf(textDt, 700, 10, 200)
    love.graphics.printf(textFps, 700, 20, 200)
    love.graphics.printf(mx .. "," .. my, 700, 30, 200)
end

return Info
