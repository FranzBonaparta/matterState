local Object = require("libs.classic")
local Particle = Object:extend()
local Tooltip = require("libs.tooltip")

function Particle:new(x, y)
  --coords : map's array
  self.x = x
  self.y = y
  self.size = 8
  --real coords in pixel
  self.px = self.x * self.size
  self.py = self.y * self.size
  self.vx = 0
  self.vy = 0
  self.color = { 255, 255, 255 }
  self.name = ""
  self.state = "gas" --or "liquid" , "solid"
  self.temperature = 20
  self.isFlammable = false
  self.isOxidant = false --comburant
  self.ignitionPoint = 300
  self.density = 5
  self.conduction = 0
  self.isBurning = false
  self.maxTemperature = self.isFlammable and 1000 or 600
  self.time = math.random() * 10
  self.stable = false
  self.toolTip = Tooltip("", self, 0.2)
  self.isHovered = false
  self.timer = 1
end

function Particle:getCoords()
  return self.px, self.py
end

function Particle:getNeighbours(map)
  local x, y = self.x, self.y
  local nx = { x - 1, x, x + 1, x - 1, x + 1, x - 1, x, x + 1 }
  local ny = { y - 1, y - 1, y - 1, y, y, y + 1, y + 1, y + 1 }
  local neighbours = {}
  for i, index in ipairs(ny) do
    if map[index] and map[index][nx[i]] then
      table.insert(neighbours, map[index][nx[i]])
    end
  end
  return neighbours
end

function Particle:getNeighboursCount(map)
  local neighbours = self:getNeighbours(map)
  local count = #neighbours
  return count
end

function Particle:propagateTemperature(map)
  local neighbours = self:getNeighbours(map)
  if self.isBurning then return end
  if #neighbours == 0 then return end
  local sumTemp = 0
  for _, neighbour in ipairs(neighbours) do
    sumTemp = sumTemp + neighbour.temperature
  end
  sumTemp = sumTemp / #neighbours
  local dtTemp = (sumTemp - self.temperature) / 2

  self.temperature = self.temperature + (dtTemp * self.conduction)
end

function Particle:initTooltip(map)
  local a, b = self:getCoords()
  -- text & tooltip construction
  local lines = {}
  local neighboursCount = self:getNeighboursCount(map)
  table.insert(lines, string.format("[%i %i]", a, b))
  table.insert(lines, string.format("Avg Temp: %.1f°C", self.temperature))
  table.insert(lines, string.format("NeighboursAmount: %i", neighboursCount))
  table.insert(lines, self.name)
  local text = table.concat(lines, "\n")
  self.toolTip:setText(text)
end

function Particle:mouseIsHover(mx, my)
  local isHover = false
  if mx >= self.px and mx <= self.px + self.size and
      my >= self.py and my <= self.py + self.size then
    isHover = true
  end
  return isHover
end

function Particle:canBurn(map)
  local bool = false
  local neighbours = self:getNeighbours(map)
  if #neighbours == 0 then return end
  for _, neighbour in ipairs(neighbours) do
    if neighbour.isOxidant then
      bool = true
      break
    end
  end
  if bool == true and self.temperature >= self.ignitionPoint and self.isFlammable then
    return true
  end
  return false
end

function Particle:draw()
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("line", self.px, self.py, self.size, self.size)
  local r, g, b = self.color[1] / 255, self.color[2] / 255, self.color[3] / 255
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle("fill", self.px, self.py, self.size, self.size)
  love.graphics.setColor(1, 1, 1)
end

function Particle:mousepressed(mx, my, button)
  if self:mouseIsHover(mx, my) and button == 1 then
    self.temperature = 500
  end
end

function Particle:update(dt, map)
  self.timer = self.timer - dt
  self.toolTip:update(dt)
  if self.timer <= 0 then
    if not self.isBurning and self:canBurn(map) then
      self.isBurning = true
    end
    self:propagateTemperature(map)
    self.timer = 0.5
  end
end

return Particle
