local Object = require("libs.classic")
local Particle = Object:extend()
local Tooltip = require("libs.tooltip")
local TemperatureManager = require("managers.temperatureManager")
local DensityManager = require("managers.densityManager")
local particleIndex = 1
function Particle:new(x, y)
  self.index = particleIndex
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
  self.lastSwapIndex = self.index
  particleIndex = particleIndex + 1
end

function Particle:getCoords()
  return self.px, self.py
end

function Particle:getNeighbours(map)
  local x, y = self.x, self.y
  --up/LeftUp/RightUp/left/right/down/leftDown/rightDown
  local nx = { x, x - 1, x + 1, x - 1, x + 1, x, x - 1, x + 1 }
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

function Particle:initTooltip(map)
  local a, b = self:getCoords()
  -- text & tooltip construction
  local lines = {}
  local neighboursCount = self:getNeighboursCount(map)
  table.insert(lines, string.format("index: %i", self.index))
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

function Particle:ignite()
  if self.isFlammable then
    self.temperature = self.ignitionPoint
    self.isBurning = true
  end
end

function Particle:update(dt, map)
  if not self.stable then
    self.stable = self.state == "solid"
  end
  self.timer = self.timer - dt
  self.toolTip:update(dt)
  if self.timer <= 0 then
    if not self.isBurning and TemperatureManager.canBurn(self, map) then
      self:ignite()
    end
    TemperatureManager.propagateTemperature(self, map)
    if not self.stable then
      DensityManager.didMove(self, map)
    end
    if self.isBurning then
      TemperatureManager.drawFlames(self)
    end
    self.timer = 0.5
  end
end

return Particle
