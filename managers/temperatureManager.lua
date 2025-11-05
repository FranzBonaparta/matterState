--[[
    TemperatureManager.lua
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

╔═════════════════════════════════════════════════════════════════════════╗
║  Component : TemperatureManager                                         ║
║  Description : Allows you to manage all temperature changes,            ║
║                their propagation and their impact on particles          ║
║                (physical and visual).                                   ║
║  Author : Jojopov                                                       ║
║  Creation : October 2025                                                ║
║  Use :                                                                  ║
║     local TemperatureManager = require("managers.temperatureManager")   ║
║     local bool=TemperatureManager.canBurn(particle,map)                 ║
╚═════════════════════════════════════════════════════════════════════════╝
]]
local TemperatureManager = {}
-- Check if the particle is flammable, hot enough to burn, and if it has a neighbor that is an oxidizer.
function TemperatureManager.canBurn(particle, map)
  local neighbours = particle:getNeighbours(map)
  if #neighbours == 0 then return false end
  for _, neighbour in ipairs(neighbours) do
    if neighbour.chemicalProperties and neighbour.chemicalProperties.isOxidant then
      return particle.temperature >= (particle.chemicalProperties.ignitionPoint - 50) and
          particle.chemicalProperties.isFlammable
    end
  end
  return false
end

function TemperatureManager.propagateTemperature(particle, map, dt)
  local delta = math.floor(dt * 1000)
  local neighbours = particle:getNeighbours(map)
  if not particle.chemicalProperties or #neighbours == 0 then return end
  -- If the particle is burning, but its temperature is still not at its maximum, then it is heating up.
  if particle.isBurning and particle.temperature <= particle.chemicalProperties.maxTemperature then
    particle.temperature = math.min(particle.temperature + delta, particle.chemicalProperties.maxTemperature)
  end
  -- Now we check if the particle has a neighbor on fire.
  local hasBurn = false
  for _, neighbour in ipairs(neighbours) do
    if neighbour.isBurning then
      hasBurn = true
      break
    end
  end

  for _, neighbour in ipairs(neighbours) do
    local diff = neighbour.temperature - particle.temperature
    --ignition
    if neighbour.isBurning and particle.chemicalProperties.isFlammable and particle.temperature >= particle.chemicalProperties.ignitionPoint - 50 then
      particle:ignite()
      break
    end
    --propagate temperature if neighbour is colder
    if particle.isBurning and diff < 1 then
      local convectionFactor = (neighbour.y < particle.y) and 2 or 1.5
      neighbour:changeTemperature(neighbour.temperature -
        diff * 0.5 * neighbour.chemicalProperties.conduction * convectionFactor)
      --else classical diffusion on self (if not burning)
    elseif not particle.isBurning and diff > 1 then
      particle:changeTemperature(particle.temperature +
        diff * 0.5 * neighbour.chemicalProperties.conduction)
      --elseif no source of heat, decrease the temperature
    elseif particle.name == "ashes" or (not particle.isBurning and not hasBurn and diff < 1) then
      particle:changeTemperature(math.max(particle.startTemperature, particle.temperature - (delta / 4)))
    end
  end
end

function TemperatureManager.manageFire(particle,map)
      -- If the particle is not yet burning, but meets all the criteria to ignite: we light it!
    if not particle.isBurning and TemperatureManager.canBurn(particle, map) then
      particle:ignite()
    else
      TemperatureManager.stopFire(particle)
    end
end

function TemperatureManager.stopFire(particle)
  -- If it is no longer burning, but still has a Löve's ParticleSystem, then the system is removed.
  if not particle.isBurning and particle.psystem then
      particle.psystem = nil
  end
end

--manage decomposition and transformation of particle due to ignition
function TemperatureManager.decomposeParticle(particle,neighbours)
  if particle.isBurning then
      -- If the particle burns, it decomposes its neighbors.
      for _, neighbour in ipairs(neighbours) do
        if not neighbour.isBurning then
          neighbour.integrity = math.max(0, neighbour.integrity - 1)
        end
      end
    end
        for _, neighbour in ipairs(neighbours) do
      -- If the neighboring particle is decomposed and it is oxygen, then it is transformed.
      if neighbour.integrity <= 0 and neighbour.name == "oxygen" then
        local child = neighbour.chemicalProperties.consumptionChild
        if child then
          neighbour:changeName(child)
          neighbour.stable = false
          neighbour.isBurning = false
        end
      end
    end
    -- If the particle is decomposed, we check that it can be transformed before starting the process.
    if particle.integrity <= 0 then
      local child = particle.chemicalProperties.consumptionChild
      if child then
        local temperature = particle.temperature
        particle:changeName(child)
        particle.temperature = temperature
        particle.isBurning = false
      end
    end
end

function TemperatureManager.drawFlames(particle)
  if particle.isBurning then
    -- this will randomly alternate between colors to represent fire!
    local rand = math.random(1, 3)
    local colors = { { 255, 0, 0 }, { 255, 128, 0 }, { 255, 255, 0 } }
    particle.color = colors[rand]
  end
end

--[[This will generate and assign a ParticleSystem to the particle.
It's the most convenient way I've found to avoid simulating each transformation
 of oxygen particles into CO2. It would have been necessary to generate
 billions of particles to obtain a realistic result!]]
function TemperatureManager.makeSmoke(particle)
  local size = particle.size / 2
  local canvas = love.graphics.newCanvas(size, size, { format = "rgba8" })
  love.graphics.push("all") -- Save all the state (blendmode, canvas, etc)
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.setBlendMode("alpha", "premultiplied") -- important
  love.graphics.setColor(125 / 255, 125 / 255, 125 / 255, 0.7)
  love.graphics.circle("fill", 0, 0, size)
  --love.graphics.rectangle("fill", 0, 0, size, size)
  love.graphics.pop()
  local psystem = love.graphics.newParticleSystem(canvas, 32)
  psystem:setParticleLifetime(2, 5) -- Particles live at least 2s and at most 5s.
  psystem:setEmitterLifetime(particle.integrity)
  psystem:setEmissionRate(5)
  psystem:setSizes(1, 2, 4) -- to test
  psystem:setSizeVariation(1)
  --ParticleSystem:setLinearAcceleration( xmin, ymin, xmax, ymax )
  psystem:setLinearAcceleration(-size - 5, -20, size + 5, 0)                                  -- Random movement in all directions.
  psystem:setColors(125 / 255, 125 / 255, 125 / 255, 0.3, 125 / 255, 125 / 255, 125 / 255, 0) -- Fade to transparency.
  particle.psystem = psystem
end

function TemperatureManager.update(particle,map,dt)
    local mapArray = map.particles
    -- First, we collect the neighboring particles
    local neighbours = particle:getNeighbours(mapArray)
    TemperatureManager.decomposeParticle(particle,neighbours)

    TemperatureManager.manageFire(particle,mapArray)
    -- We initiate the temperature propagation.
    TemperatureManager.propagateTemperature(particle, mapArray, dt)
        -- If the particle burns, then it decomposes. And its properties (colors)
    -- are modified to visually make it appear to be on fire.
    if particle.isBurning then
      particle.integrity = particle.integrity - particle.chemicalProperties.consumptionRate
      TemperatureManager.drawFlames(particle)
    end
end

return TemperatureManager
