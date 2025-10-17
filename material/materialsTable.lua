local Object = require("libs.classic")
local MaterialsTable = Object:extend()
local Element = require("material.material")
local CombustionManager=require("combustionManager")
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
  CombustionManager.ignite(self.elements)
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
  local directions={"left","up","right","down"}

  local indiceX, indiceY = self:getElementIndice(element)
  local dx, dy = { indiceX - 1, indiceX, indiceX + 1, indiceX },
      { indiceY, indiceY - 1, indiceY, indiceY + 1 }
  for i = 1, 4, 1 do
    if dy[i] >= 1 and dx[i] >= 1
        and dy[i] <= maxY and dx[i] <= maxX then
      table.insert(materialsNeighbours, {direction=directions[i],value=self.elements[dy[i]][dx[i]]})
    end
  end
  return materialsNeighbours
end

--tiles= incoming neighbours from map
function MaterialsTable:getNeighbours(tiles, element)
  local materialsNeighbours = {}
  local neighbours=self:getDirectNeighbours(element)
  local directions={"left","up","right","down"}

  --tiles=neighbours of self tile
  local indiceX, indiceY = self:getElementIndice(element)
  local dx, dy = { 4, indiceX, 1, indiceX },
      { indiceY, 4, indiceY, 1 }
      for i = 1, #neighbours, 1 do
        for j = #directions,1, -1 do
          if neighbours[i].direction==directions[j] then
            table.remove(directions,j)
            table.remove(dx,j)
            table.remove(dy,j)
            break
          end
        end
      end
      --then we can attributes our neighbours elements
      for _, neighbour in ipairs(tiles) do
        for i = 1, #directions, 1 do
          if neighbour.direction==directions[i] then
            local y,x=dy[i],dx[i]
            table.insert(materialsNeighbours,{direction=directions[i],value=neighbour.value.materials.elements[y][x]})
          end
        end
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

function MaterialsTable:update(dt,tiles)
  self.coolDown = self.coolDown - dt
  if self.coolDown <= 0 then
    CombustionManager.update(dt,self,tiles)
    for _, line in ipairs(self.elements) do
      for _, element in ipairs(line) do
        element:update(dt)
      end
    end
    self.coolDown = 0.5
  end
end

return MaterialsTable
