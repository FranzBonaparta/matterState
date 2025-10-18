local DensityManager = {}

function DensityManager.isFluid(elementsTable)
  for _, line in ipairs(elementsTable) do
    for _, element in ipairs(line) do
      if element.state == "gas" then
        return true
      end
    end
  end
  return false
end
function DensityManager.swap(n1,n2)
  local e1,e2=n1.value,n2.value
  local mt1,mt2=n1.parentGrid,n2.parentGrid
  local x1,y1=n1.dx,n1.dy
  local x2,y2=n2.dx,n2.dy
  mt1[y1][x1],mt2[y2][x2]=e2,e1
  e1.x, e1.y, e2.x, e2.y = e2.x, e2.y, e1.x, e1.y

end
function DensityManager.isLessDense(elementX, elementY)
  if elementX.value.density < elementY.value.density and 
  elementX.value.x==elementY.value.x and elementX.value.y > elementY.value.y and
   elementX.value.state=="gas" and elementY.value.state== "gas"then
    DensityManager.swap(elementX,elementY)
  end
end

function DensityManager.update(materialsTable, tiles)
  if DensityManager.isFluid(materialsTable.elements) then
    for _, line in ipairs(materialsTable.elements) do
      for _, element in ipairs(line) do
        local neighbours = materialsTable:getDirectNeighbours(element)
        for _, neighbour in ipairs(neighbours) do
          local formatted=materialsTable:getFormattedElement(element)
          DensityManager.isLessDense(neighbour,formatted)
        end
        if materialsTable:isOnBorder(element.x,element.y) then
          neighbours=materialsTable:getNeighbours(tiles,element)
          for _, neighbour in ipairs(neighbours) do
            if neighbour.value and neighbour.value.x and neighbour.value.y then
              local formatted=materialsTable:getFormattedElement(element)
              DensityManager.isLessDense(neighbour,formatted)
            end
          end
        end
      end
    end
  end
end

return DensityManager
