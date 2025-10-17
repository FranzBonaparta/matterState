local CombustionManager = {}

function CombustionManager.ignite(elementsTable)
  local randomX, randomY = math.random(4), math.random(4)
  local randomElement = elementsTable[randomY][randomX]
  randomElement:ignite()
end

function CombustionManager.canBurn(elementsTable)
  for _, line in ipairs(elementsTable) do
    for _, element in ipairs(line) do
      if element.isOxidant then
        return true
      end
    end
  end
  return false
end

function CombustionManager.didBurn(elementsTable)
  for _, line in ipairs(elementsTable) do
    for _, element in ipairs(line) do
      if element.isBurning then
        --print("is burning")
        return true
      end
    end
  end
  return false
end

function CombustionManager.getBurningMaterials(elementsTable)
  local burnings = {}
    for _, line in ipairs(elementsTable) do
      for _, element in ipairs(line) do
        if element.isBurning then
          table.insert(burnings, element)
        end
      end
    
  end
  return burnings
end


function CombustionManager.update(dt, materialsTable, tiles)
  if CombustionManager.didBurn(materialsTable.elements) then
    local burnings = CombustionManager.getBurningMaterials(materialsTable.elements)
      for _, burning in ipairs(burnings) do
        local neighbours = materialsTable:getDirectNeighbours(burning)
        for _, element in ipairs(neighbours) do
          if element.value and element.value.temperature and element.value.changeTemperature then
            element.value:changeTemperature(10)
          end
        end
        if materialsTable:isOnBorder(burning.x, burning.y) then
          neighbours = materialsTable:getNeighbours(tiles, burning)
          for _, neighbour in ipairs(neighbours) do
            if neighbour.value and neighbour.value.x and neighbour.value.y
                and neighbour.value.temperature and neighbour.value.changeTemperature then
              neighbour.value:changeTemperature(10)
            end
          end
        end
      end
  end
end

return CombustionManager
