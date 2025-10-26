local DensityManager = {}

function DensityManager.didMove(particle, map)
  local neighbours = particle:getNeighbours(map)
    for i = #neighbours, 1, -1 do
      local neighbour=neighbours[i]
      local incompatible=neighbour.state=="solid" or particle.state~= neighbour.state
      local recentSwap=particle.lastSwapIndex == neighbour.index
      local tooDense=particle.density>=neighbour.density
      local tooLow=particle.y<neighbour.y
      if incompatible or recentSwap or tooDense or tooLow then
        table.remove(neighbours,i)
      end
    end
    particle.stable=(#neighbours==0)  
    if not particle.stable then
      local x, y = particle.x, particle.y
      local neighbour = neighbours[1]
      local nx, ny = neighbour.x, neighbour.y
      local px, py = particle.px, particle.py
      local npx, npy = neighbour.px, neighbour.py
      particle.lastSwapIndex = neighbour.index
      neighbour.lastSwapIndex = particle.index
      particle.px, particle.py = npx, npy
      particle.x, particle.y = nx, ny
      neighbour.px, neighbour.py = px, py
      neighbour.x, neighbour.y = x, y
      map[y][x] = neighbour
      map[ny][nx] = particle
    end
end

return DensityManager
