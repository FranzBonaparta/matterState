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
  local neighbours = particle:getNeighbours(map.particles)
  for i = #neighbours, 1, -1 do
    local neighbour = neighbours[i]
    -- If the neighboring substance is solid or not of the same type (liquid, gas): it is incompatible
    local incompatible = neighbour.state == "solid" or
        particle.chemicalProperties.state ~= neighbour.chemicalProperties.state
    -- We want to avoid a back-and-forth.
    local recentSwap = particle.lastSwapIndex == neighbour.index
    -- Only particles that are less dense than their neighbors move.
    local tooDense = particle.chemicalProperties.density >= neighbour.chemicalProperties.density
    -- A particle only moves if it is above or next its neighbor.
    local tooLow = particle.y < neighbour.y
    -- We only keep the neighboring particles eligible for position exchange.
    if incompatible or recentSwap or tooDense or tooLow then
      table.remove(neighbours, i)
    end
  end
  -- If there are no more neighbors left, then the particle is stable.
  particle.stable = (#neighbours == 0)
  -- If, despite this, the particle is unstable, then we proceed with the exchange of positions.
  if not particle.stable then
    --particle:swap(neighbours[1],map)
    map:swapParticles(particle, neighbours[1])
  end
end

function DensityManager.didFall(particle, map)
  local downNeighbour = particle:getNeighbour(map.particles, "down")
  --local neighbours = particle:getNeighbours(map)

  if downNeighbour then
    if downNeighbour.chemicalProperties.state == "solid" and downNeighbour.stable then
      particle.stable = true
    elseif downNeighbour.chemicalProperties.state ~= "solid" and downNeighbour.chemicalProperties.state ~= "granular" then
      -- on tombe
      map:swapParticles(particle, downNeighbour)
    elseif downNeighbour.chemicalProperties.state == "solid" then
      particle.stable = downNeighbour.stable
    elseif downNeighbour.chemicalProperties.state == "granular" and downNeighbour.stable then
      particle.stable = true
    end
  else
    particle.stable = true
  end
end

function DensityManager.allAreStable(neighbours)
  for _, n in ipairs(neighbours) do
    local s = n.chemicalProperties.state
    --If the neighbour is liquid or gas, we fall
    if not n.stable or s == "liquid" or s == "gas" then
      return false
    end
  end
  return true
end

function DensityManager.getUnstableNeighbours(neighbours)
  local elligibles = {}
  for _, neighbour in ipairs(neighbours) do
    local state = neighbour.chemicalProperties.state
    --If the neighbour is liquid or gas, the particule is elligible to swap
    if (state == "granular" and not neighbour.stable) or state == "gas" or state == "liquid" then
      table.insert(elligibles, neighbour)
    end
  end
  return elligibles
end

function DensityManager.didSlide(particle, map)
  local down = particle:getNeighbour(map.particles, "down")

  if down then
    --else check if the down neighbour is a stable solid particle
    local s = down.chemicalProperties.state
    if s == "gas" or s == "liquid" then
      map:swapParticles(particle, down)
      particle.stable = false
      --particle:setColor(0, 255, 0)

      return
    end
    --else:make more checks
    local downNeighbours = particle:getNeighbours(map.particles, { "downLeft", "downRight" })
    table.insert(downNeighbours, down)

    local stable = DensityManager.allAreStable(downNeighbours)
    if not stable and down.chemicalProperties.state ~= "solid" then
      local elligibles = DensityManager.getUnstableNeighbours(downNeighbours)
      if #elligibles > 0 then
        particle.stable = false
        local target = elligibles[math.random(1, #elligibles)]
        -- on tombe
        if target.chemicalProperties.state == "granular" then
          particle.stable = true
          --[[particle:setColor(255, 0, 0)
          else
            particle:setColor(0, 0, 255)]]
        end
        map:swapParticles(particle, target)
        return
      end
    end
  end
  --check if we are on map's border
  particle.stable = true
  --particle:setColor(255, 0, 0)
end

--dispatch comportment depending on particle's state
function DensityManager.chooseAction(particle, map)
  local states = { "solid", "granular", "liquid", "gas" }
  local actions = { DensityManager.didFall, DensityManager.didSlide, DensityManager.didMove, DensityManager.didMove }
  for i = 1, #states, 1 do
    if particle.chemicalProperties.state == states[i] then
      actions[i](particle, map)
      break
    end
  end
end

--check if the particle need to be activated
function DensityManager.resetMove(particle, map)
  local d = particle:getNeighbour(map, "down")
  local u = particle:getNeighbour(map, "up")
  --if there is no particule solid or granular under, we can fall again!
  if particle.chemicalProperties.state == "solid" or particle.chemicalProperties.state == "granular" then
    --check if we are solid or "gas"
    if d and d.chemicalProperties.state ~= "solid" and d.chemicalProperties.state ~= "granular" then
      particle.stable = false
      d.stable = false
    end
  end
  if (particle.chemicalProperties.state == "gas") and d then
    if particle.chemicalProperties.density > d.chemicalProperties.density and d.chemicalProperties.state == "gas" then
      particle.stable = false
      d.stable = false
    end
  end
  if (particle.chemicalProperties.state == "gas") and u then
    if particle.chemicalProperties.density < u.chemicalProperties.density and u.chemicalProperties.state == "gas" then
      particle.stable = false
      u.stable = false
    end
  end
end

function DensityManager.update(particle, map)
  -- We check if the particule need to move.
  if not particle.stable then
    DensityManager.chooseAction(particle, map)
  end
  if particle.stable then
    DensityManager.resetMove(particle, map.particles)
  end
end

return DensityManager
