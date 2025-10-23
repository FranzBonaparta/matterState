local Object = require("libs.classic")
local Material = Object:extend()
local MaterialsData = require("material.materialsData")

function Material:new(x, y, size, name)
  self.x = x
  self.y = y
  self.size = size
  self.color = { 255, 255, 255 }
  self.name = name
  self.state = "gas" --or "liquid" , "solid"
  self.temperature = 20
  self.isFlammable = false
  self.isOxidant = false --comburant
  self.ignitionPoint = 300
  self.density = 5
  self.conduction = 0
  self.isBurning = false
  self.maxTemperature=self.isFlammable and 1000 or 600
  self.time = math.random() * 10
  self.canMove=true
  self:changeName(name)
end

function Material:changeName(name)
  local newMaterial = MaterialsData.getMaterialByName(name)
  if newMaterial then
    self.name = newMaterial.name
    self.state = newMaterial.state
    self.temperature = newMaterial.temperature
    self.isFlammable = newMaterial.flammable
    self.isOxidant = newMaterial.oxidant
    self.ignitionPoint = newMaterial.ignitionPoint
    self.density = newMaterial.density
    self.conduction = newMaterial.conduction
    self.color = newMaterial.colors
  else
    print(string.format("'%s' doesn't exist on material's table!"), name)
  end
end

function Material:canBurn()
  if self.isFlammable and self.temperature >= self.ignitionPoint then
    return true
  end
end
function Material:swapMove(bool)
  self.canMove=bool
end
function Material:draw()
  local r, g, b = self.color[1] / 255, self.color[2] / 255, self.color[3] / 255
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
  love.graphics.setColor(1, 1, 1)
end

function Material:setColor(colorArray)
  self.color = { colorArray[1], colorArray[2], colorArray[3] }
end

function Material:update(dt)
  if self.isBurning or self.temperature >=self.ignitionPoint then
    self.time=self.time+dt
    self:setColor(self:getBurningColor())
  end
end
function Material:getBurningColor()
  local index = math.floor(self.time * 5) % 3 + 1
  local colors = {
    {255, 0, 0},
    {255, 128, 0},
    {255, 255, 0}
  }
  return colors[index]
end

function Material:changeTemperature(amount)
  if not self.isBurning then
    self.temperature=math.min(self.temperature+amount,self.maxTemperature)
    if self.temperature >=self.ignitionPoint then
      self:ignite()
    end
  end
end
function Material:ignite()
  if self.isFlammable and not self.isBurning then
    self.temperature = 400
    self.isBurning = true
  end
end

return Material
