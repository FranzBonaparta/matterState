local Object = require("libs.classic")
local MaterialsTable = Object:extend()
local Element = require("material.material")

function MaterialsTable:new(x, y, size)
  self.x = x
  self.y = y
  self.size = size --32
  self.elements = {}
  self.step = 8
  self.coolDown = 0.2
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

function MaterialsTable:getElementIndice(element)
  local x, y = (element.x - self.x) / self.step,
      (element.y - self.y) / self.step

  return math.floor(x) + 1, math.floor(y) + 1
end

function MaterialsTable:ignite()
  local randomX, randomY = math.random(4), math.random(4)
  local randomElement = self.elements[randomY][randomX]
  randomElement:ignite()
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
  return burnings
end

function MaterialsTable:isOnBorder(x, y)
  if x == self.x or y == self.y or
      x == self.x + 24 or y == self.y + 24 then
    return true
  end
  return false
end

function MaterialsTable:getDirectNeighbours(element)
  local materialsNeighbours = {}
  local maxX = #self.elements[1]
  local maxY = #self.elements
  local indiceX, indiceY = self:getElementIndice(element)
  local dx, dy = { indiceX - 1, indiceX, indiceX + 1, indiceX },
      { indiceY, indiceY - 1, indiceY, indiceY + 1 }
  for i = 1, 4, 1 do
    if dy[i] >= 1 and dx[i] >= 1
        and dy[i] <= maxY and dx[i] <= maxX then
      table.insert(materialsNeighbours, self.elements[dy[i]][dx[i]])
    else
      table.insert(materialsNeighbours, nil)
    end
  end
  return materialsNeighbours
end

--tiles= incoming neighbours from map
function MaterialsTable:getNeighbours(neighbours, element)
  local materialsNeighbours = {}
  local directions = {
    [1] = "left",
    [2] = "up",
    [3] = "right",
    [4] = "down"
  }
  --tiles=neighbours of self tile
  local indiceX, indiceY = self:getElementIndice(element)
  local dx, dy = { indiceX - 1, indiceX, indiceX + 1, indiceX },
      { indiceY, indiceY - 1, indiceY, indiceY + 1 }
  local maxX = #self.elements[1]
  local maxY = #self.elements
  for i = 1, 4, 1 do
    if dy[i] >= 1 and dx[i] >= 1
        and dy[i] <= maxY and dx[i] <= maxX then
      table.insert(materialsNeighbours, self.elements[dy[i]][dx[i]])
    else
      local neighbour = neighbours[i]
      local nEIX = 0
      nEIX = dx[i] < 1 and maxX or (dx[i] > maxX and 1 or dx[i])
      local nEIY = 0
      nEIY = dy[i] < 1 and maxY or (dy[i] > maxY and 1 or dy[i])
      if neighbour and neighbour.elements and neighbour.elements[nEIY] and neighbour.elements[nEIY][nEIX] then
        table.insert(materialsNeighbours, neighbour.elements[nEIY][nEIX])
      else
        table.insert(materialsNeighbours, {})
      end
    end
  end

  return {
    left  = materialsNeighbours[1],
    up    = materialsNeighbours[2],
    right = materialsNeighbours[3],
    down  = materialsNeighbours[4]
  }
end

function MaterialsTable:draw()
  for _, line in ipairs(self.elements) do
    for _, element in ipairs(line) do
      element:draw()
    end
  end
end

function MaterialsTable:update(dt)
  self.coolDown = self.coolDown - dt
  if self.coolDown <= 0 then
    if self:didBurn() then
      local burnings = self:getBurningMaterials()
      for _, burning in ipairs(burnings) do
        local neighbours = self:getDirectNeighbours(burning)
        for _, element in ipairs(neighbours) do
          if element and element.temperature and not element.isBurning then
            element.temperature = element.temperature + 10

            if element.temperature >= 400 then
              element:ignite()
            end
          end
        end
      end
    end
    self.coolDown = 0.5
  end
end

--if self:didBurn() then
--local burnings = self:getBurningMaterials()
--if #burnings == 0 then
--[[
    for _, line in ipairs(self.elements) do
      for _, element in ipairs(line) do
        local sumTemp = 0
        local count = 0
        local elementNeighbours = self:getNeighbours(neighbours, element)


        for _, value in ipairs(elementNeighbours) do
          if value and value.temperature then
            sumTemp = sumTemp + value.temperature
            count = count + 1
          end
        end
        if count > 0 then
          local avgTemp = sumTemp / count
          -- interpolation douce vers la température moyenne des voisins
          element.temperature = element.temperature + (avgTemp - element.temperature) * 0.1
        end
        element:update(dt)
      end
    end]]

--end

--end

return MaterialsTable
