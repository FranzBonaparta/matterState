local Object = require("libs.classic")
local Particle = require("particles.particle")
local Map = Object:extend()

function Map:new()
  self.particles = {}
end

function Map:init(size)
  self.particles = {}
  for y = 1, size, 1 do
    table.insert(self.particles, {})
    for x = 1, size, 1 do
      local particle = Particle(x, y)
      local name = ""
      if y >= size - 4 then
        if x % 16 == 10 or x % 16 == 11 or x % 16 == 12 or x % 16 == 13 then
          name = "stone"
        else
          name = "soil"
        end
      elseif y < size - 4 and y > 40 and (x % 20 ==10 or x % 20 ==11 or x % 20 ==12) then
        name = "wood"
      elseif (y <= size - 4 and y >= size - 12) and x % 20 ~= 10 then
        name = "carbonDioxide"
      else
        name = "oxygen"
      end
      particle:changeName(name)
      table.insert(self.particles[y], particle)
    end
  end
end

function Map:draw()
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      particle:draw()
    end
  end
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      particle.toolTip:draw()
    end
  end
end
function Map:mousepressed(mx,my,button)
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      particle:mousepressed(mx,my,button)
    end
  end
end
function Map:update(dt)
  local mx, my = love.mouse.getPosition()
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      particle:update(dt, self.particles)
      if particle:mouseIsHover(mx, my) then
        particle:initTooltip(self.particles)
      end
    end
  end
end

return Map
