--[[
    densityManager.lua
    Copyright (C) 2025 Jojopov

    This file is part of the MatterStates project.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License published by the Free Software Foundation,
either version 3 of the license, or (at your option) any later version.

This program is distributed in the hope that it will be useful,

but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for details.

You should have received a copy of the GNU General Public License
with this program. If not, see <https://www.gnu.org/licenses/>.

╔════════════════════════════════════════════════════════════════╗
║  Component : DensityManager                                    ║
║  Description : Manages how particles evolve based              ║
║                 on their density and environment.              ║
║  Author : Jojopov                                              ║
║  Creation : October 2025                                       ║
║  Use :                                                         ║
║     local DensityManager = require("managers.densityManager")  ║
║     DensityManager.didMove(particle,map)                       ║
╚════════════════════════════════════════════════════════════════╝
]]
local DensityManager = {}
-- We are trying to determine if the targeted particle needs to move.
function DensityManager.didMove(particle, map)
  --  In the case of movement, we collect neighboring particles.
  local neighbours = particle:getNeighbours(map)
    for i = #neighbours, 1, -1 do
      local neighbour=neighbours[i]
      -- If the neighboring substance is solid or not of the same type (liquid, gas): it is incompatible
      local incompatible=neighbour.state=="solid" or particle.chemicalProperties.state~= neighbour.chemicalProperties.state
      -- We want to avoid a back-and-forth.
      local recentSwap=particle.lastSwapIndex == neighbour.index
      -- Only particles that are less dense than their neighbors move.
      local tooDense=particle.chemicalProperties.density>=neighbour.chemicalProperties.density
      -- A particle only moves if it is above or next its neighbor.
      local tooLow=particle.y<neighbour.y
      -- We only keep the neighboring particles eligible for position exchange.
      if incompatible or recentSwap or tooDense or tooLow then
        table.remove(neighbours,i)
      end
    end
    -- If there are no more neighbors left, then the particle is stable.
    particle.stable=(#neighbours==0)
    -- If, despite this, the particle is unstable, then we proceed with the exchange of positions.
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
      -- And we push the modified particules into the map
      map[y][x] = neighbour
      map[ny][nx] = particle
    end
end

return DensityManager
