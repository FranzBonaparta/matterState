local Object = require("libs.classic")

local Particle = Object:extend()

function Particle:new(x, y)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.size = 2
    self.stable = false
end

function Particle:draw()
    love.graphics.setColor(255 / 255, 215 / 255, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
end

return Particle