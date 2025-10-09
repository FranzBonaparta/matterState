local Object = require("libs.classic")
local MaterialsTable = Object:extend()
local Element = require("material.material")

function MaterialsTable:new(x, y, size)
  self.x = x
  self.y = y
  self.size = size --32
  self.elements = {}
  self.step = 8
  self.coolDown = 1
end

function MaterialsTable:initElements(name)
  local index = 1
  for y = self.y, self.y + self.size - 8, 8 do
    table.insert(self.elements, {})
    for x = self.x, self.x + self.size - 8, 8 do
      local element = Element(x, y, 8, name)
      table.insert(self.elements[index], element)
    end
    index = index + 1
  end
end

function MaterialsTable:canBurn()
  for _, line in ipairs(self.elements) do
    for _, element in ipairs(line) do
      if element.isOxidant then
        return true
      end
    end
  end
  return false
end

function MaterialsTable:didBurn()
  for _, line in ipairs(self.elements) do
    for _, element in ipairs(line) do
      if element.isBurning then
        return true
      end
    end
  end
  return false
end

function MaterialsTable:getBurningMaterials()
  local burnings = {}
  for _, line in ipairs(self.elements) do
    for _, element in ipairs(line) do
      if element.isBurning then
        table.insert(burnings, element)
      end
    end
  end
end

function MaterialsTable:isOnBorder(x, y)
  if x == self.x or y == self.y or
      x == self.x + 24 or y == self.y + 24 then
    return true
  end
  return false
end

--tiles= incoming neighbours from map
function MaterialsTable:getNeighbours(neighbours, element)
  local materialsNeighbours = {nil,nil,nil,nil}
  --tiles=neighbours of self tile
  local dx,dy={(element.x-8)/self.x,(element.x)/self.x,(element.x+8)/self.x,(element.x)/self.x},
  {(element.y)/self.y,(element.y-8)/self.y,(element.y)/self.y,(element.y+8)/self.y}
  for _, value in ipairs(self.elements) do

  end
  return materialsNeighbours
end

function MaterialsTable:draw()
  for _, line in ipairs(self.elements) do
    for _, element in ipairs(line) do
      element:draw()
    end
  end
end

function MaterialsTable:update(dt, tiles)
  self.coolDown = self.coolDown - dt
  if self.coolDown <= 0 then
    if self:didBurn() then
      local burnings = self:getBurningMaterials()
      if #burnings == 0 then

      end
    else

    end
    self.coolDown = 0.5
  end
end

return MaterialsTable
