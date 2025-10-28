local Object = require("libs.classic")
local Particle = Object:extend()
local Tooltip = require("libs.tooltip")
local TemperatureManager = require("managers.temperatureManager")
local DensityManager = require("managers.densityManager")
local ParticlesData = require("particles.particlesData")
local ChemicalProperties = require("particles.chemicalProperties")
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
  self.chemicalProperties = nil
  self.startTemperature=20
  self.temperature = 20
  self.isBurning = false
  self.time = math.random() * 10
  self.stable = false
  self.toolTip = Tooltip("", self, 0.2)
  self.isHovered = false
  self.timer = 1
  self.integrity=100
  self.lastSwapIndex = self.index
  self.psystem=nil
  particleIndex = particleIndex + 1
end

function Particle:changeName(name)
  local newParticle = ParticlesData.getParticleByName(name)
  if newParticle then
    self.name = newParticle.name
    self.startTemperature=newParticle.temperature
    self.temperature = newParticle.temperature
    self.color = newParticle.colors
    self.integrity=100
    if not self.chemicalProperties then
      self.chemicalProperties = ChemicalProperties(name)
    else
      self.chemicalProperties:init(name)
    end
  else
    print(string.format("'%s' doesn't exist on particles's table!", name))
  end
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
  table.insert(lines,string.format("integrity: %i",self.integrity))
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
  if self.psystem then
    love.graphics.draw(self.psystem,self.px,self.py)
  end
  love.graphics.setColor(1, 1, 1)
end

function Particle:mousepressed(mx, my, button)
  if self:mouseIsHover(mx, my) and button == 1 then
    self.temperature = 500
  end
end

function Particle:ignite()
  if self.chemicalProperties and self.chemicalProperties.isFlammable and not self.isBurning then
    self.temperature = self.chemicalProperties.ignitionPoint
    self.isBurning = true
    TemperatureManager.makeSmoke(self)
  end
end

function Particle:update(dt, map)
  if not self.stable and self.chemicalProperties then
    self.stable = self.chemicalProperties.state == "solid"
  end
  self.timer = self.timer - dt
  self.toolTip:update(dt)
  if self.timer <= 0 then
    if self.integrity<=0 then
      local temperature=self.temperature
      local name=self.name=="wood" and "charcoal" or "ashes"
      if name=="ashes" then
        self.psystem=nil
      end
      self:changeName(name)
      self.temperature=temperature
      self.isBurning=false
    end
    if not self.isBurning and TemperatureManager.canBurn(self, map) then
      self:ignite()
    end
    TemperatureManager.propagateTemperature(self, map)
    if not self.stable then
      DensityManager.didMove(self, map)
    end
    if self.isBurning then
      self.integrity=self.integrity-self.chemicalProperties.consumptionRate
      TemperatureManager.drawFlames(self)
    end
    self.timer = 0.5
  end
  if self.psystem then
    self.psystem:update(dt)
    self.psystem:setEmitterLifetime(self.integrity)
  end
end

return Particle
