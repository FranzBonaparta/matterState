--[[
    Particle.lua
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
║  Component : Particle                                          ║
║  Description : Allows you to simulate the behavior of a        ║
║                chemical particle on a map.                     ║
║  Author : Jojopov                                              ║
║  Creation : September 2025                                     ║
║  Use :                                                         ║
║     local Particle = require("particle")                       ║
║     local particle = Particle(5,6)                             ║
║     particle:update(dt); particle:draw()                       ║
╚════════════════════════════════════════════════════════════════╝
]]
local Object = require("libs.classic")
local Particle = Object:extend()
local Tooltip = require("libs.tooltip")
local TemperatureManager = require("managers.temperatureManager")
local DensityManager = require("managers.densityManager")
local ParticlesData = require("particles.particlesData")
local ChemicalProperties = require("particles.chemicalProperties")
-- We define an index in order to better identify each particle
local particleIndex = 1
function Particle:new(x, y)
  self.index = particleIndex
  --coords : map's array [y][x]
  self.x = x
  self.y = y
  self.size = 8
  --real coords in pixel
  self.px = self.x * self.size
  self.py = self.y * self.size
  -- speed into px axe
  self.vx = 0
  -- speed into py axe
  self.vy = 0
  self.color = { 0, 0, 0 }
  self.name = ""
  self.chemicalProperties = nil
  self.startTemperature = 20
  self.temperature = 20
  self.isBurning = false -- Define if the particule is burning or not
  self.time = math.random() * 10
  self.stable = false    -- Determine if the particule need to move
  self.toolTip = Tooltip("", self, 0.2)
  self.isHovered = false -- Activate or desactivate the Tooltip
  self.timer = 1         -- Limits updates to save calculations.

  self.integrity = 100   -- If this number reaches zero, the particle,
  -- if it can, decomposes into another substance.
  self.lastSwapIndex = self.index
  self.psystem = nil -- Löve's ParticleSystem
  particleIndex = particleIndex + 1
end

--[[This function is called during particle creation and transformation,
 in order to automatically assign it its chemical properties.]]
function Particle:changeName(name)
  local newParticle = ParticlesData.getParticleByName(name)
  if newParticle then
    self.name = newParticle.name
    self.startTemperature = newParticle.temperature
    self.temperature = newParticle.temperature
    self:setColor(newParticle.colors[1], newParticle.colors[2], newParticle.colors[3])
    self.integrity = 100
    if not self.chemicalProperties then
      self.chemicalProperties = ChemicalProperties(name)
    else
      self.chemicalProperties:init(name)
    end
    self.stable = false
  else
    print(string.format("'%s' doesn't exist on particles's table! ref %s", name, self.name))
  end
end

-- Allows control of temperature changes
function Particle:changeTemperature(temp)
  local max = math.min(temp, self.chemicalProperties.maxTemperature)
  self.temperature = max
end

-- Defines how to retrieve pixel coordinates
function Particle:getCoords()
  return self.px, self.py
end

function Particle:setColor(r, g, b)
  r, g, b = love.math.colorFromBytes(r, g, b)
  self.color = { r, g, b }
end

-- Thanks to the particle array given as a parameter
--(two-dimensional array), we retrieve the neighboring particles.
function Particle:getNeighbours(map, directions)
  directions = directions or { "top", "down", "right", "left", "topRight", "topLeft", "downRight", "downLeft" }
  local neighbours = {}

  -- Thus, the order of checks is as follows:
  for _, d in ipairs(directions) do
    local neighbour = self:getNeighbour(map, d)
    if neighbour then
      table.insert(neighbours, neighbour)
    end
  end

  return neighbours
end

function Particle:getNeighbour(map, direction)
  local x, y = self.x, self.y
  local directions = { "top", "down", "right", "left", "topRight", "topLeft", "downRight", "downLeft" }
  local nx, ny = { x, x, x + 1, x - 1, x + 1, x - 1, x + 1, x - 1 },
      { y - 1, y + 1, y, y, y - 1, y - 1, y + 1, y + 1 }
  for i = 1, #directions, 1 do
    if direction == directions[i] then
      if map[ny[i]] and map[ny[i]][nx[i]] then
        return map[ny[i]][nx[i]]
      end
    end
  end
  return nil
end

-- Just a function created for convenience to retrieve the number of neighboring particles.
function Particle:getNeighboursCount(map)
  local neighbours = self:getNeighbours(map)
  local count = #neighbours
  return count
end

-- Here, we initialize the Tooltip
function Particle:initTooltip(map)
  local a, b = self:getCoords()
  -- text & tooltip construction
  local lines = {}
  local neighboursCount = self:getNeighboursCount(map)
  table.insert(lines, string.format("index: %i", self.index))
  table.insert(lines, string.format("[%i %i]", a, b))
  table.insert(lines, string.format("Avg Temp: %.1f°C", self.temperature))
  table.insert(lines, string.format("NeighboursAmount: %i", neighboursCount))
  table.insert(lines, string.format("integrity: %i, density: %.2f", self.integrity,self.chemicalProperties.density))
  local stable = self.stable and "stable" or "unstable"
  table.insert(lines, string.format("%s %s", self.name, stable))
  table.insert(lines, string.format("%s", self.chemicalProperties.state))
  local text = table.concat(lines, "\n")
  self.toolTip:setText(text)
end

-- We check if the mouse is hover the particle
function Particle:mouseIsHover(mx, my)
  local isHover = false
  if mx >= self.px and mx <= self.px + self.size and
      my >= self.py and my <= self.py + self.size then
    isHover = true
  end
  return isHover
end

function Particle:draw()
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("line", self.px, self.py, self.size, self.size)
  love.graphics.setColor(self.color[1], self.color[2], self.color[3])
  love.graphics.rectangle("fill", self.px, self.py, self.size, self.size)
  -- this draws smoke if the particle is burning
  if self.psystem then
    love.graphics.draw(self.psystem, self.px, self.py)
  end
  love.graphics.setColor(1, 1, 1)
end

-- This allows us to ignite a particle with the mouse
function Particle:mousepressed(mx, my, button)
  if self:mouseIsHover(mx, my) and button == 1 then
    self.temperature = 500
  end
end

-- we check here, if the particle can burn. If yes: ignite it !
function Particle:ignite()
  if self.chemicalProperties and self.chemicalProperties.isFlammable and not self.isBurning then
    self.temperature = self.chemicalProperties.ignitionPoint
    self.isBurning = true
    TemperatureManager.makeSmoke(self)
  end
end

--[[For this update, we will need to consider the particle as
well as its neighbors: their stability, their integrity,
whether they are already burning.
We will also need to propagate temperature, fire, smoke, etc.]]
function Particle:update(dt, map)
  -- First, we check if the particle is solid; in which case it must be stable.
  --[[  if not self.stable and self.chemicalProperties then
    self.stable = self.chemicalProperties.state == "solid"
  end]]
  -- The timer decreases with each frame.
  local mapArray = map.particles
  self.timer = self.timer - dt
  self.toolTip:update(dt)
  -- If the timer has finished, then we can update.
  if self.timer <= 0 then
    -- First, we collect the neighboring particles
    local neighbours = self:getNeighbours(mapArray)
    if self.isBurning then
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
    if self.integrity <= 0 then
      local child = self.chemicalProperties.consumptionChild
      if child then
        local temperature = self.temperature
        self:changeName(child)
        self.temperature = temperature
        self.isBurning = false
      end
    end
    -- If the particle is not yet burning, but meets all the criteria to ignite: we light it!
    if not self.isBurning and TemperatureManager.canBurn(self, mapArray) then
      self:ignite()
      -- If it is no longer burning, but still has a Löve's ParticleSystem, then the system is removed.
    elseif not self.isBurning and self.psystem then
      self.psystem = nil
    end
    -- We initiate the temperature propagation.
    TemperatureManager.propagateTemperature(self, mapArray, dt)
    -- We check if the particule need to move.
    if not self.stable then
      local states = { "solid", "granular", "liquid", "gas" }
      local actions = { DensityManager.didFall, DensityManager.didSlide, DensityManager.didMove, DensityManager.didMove }
      for i = 1, #states, 1 do
        if self.chemicalProperties.state == states[i] then
          actions[i](self, map)
          break
        end
      end
    end
    if self.stable then
      local d = self:getNeighbour(mapArray, "down")
      local u = self:getNeighbour(mapArray, "up")
      --if there is no particule solid or granular under, we can fall again!
      if self.chemicalProperties.state == "solid" or self.chemicalProperties.state == "granular" then
        --check if we are solid or "gas"
        if d and d.chemicalProperties.state ~= "solid" and d.chemicalProperties.state ~= "granular" then
          self.stable = false
          d.stable=false
        end
      end
      if (self.chemicalProperties.state == "gas") and d then
        if self.chemicalProperties.density > d.chemicalProperties.density and d.chemicalProperties.state == "gas" then
          self.stable = false
          d.stable=false
        end
      end
      if (self.chemicalProperties.state == "gas") and u then
        if self.chemicalProperties.density < u.chemicalProperties.density and u.chemicalProperties.state == "gas" then
          self.stable = false
          u.stable=false
        end
      end
    end

    -- If the particle burns, then it decomposes. And its properties (colors)
    -- are modified to visually make it appear to be on fire.
    if self.isBurning then
      self.integrity = self.integrity - self.chemicalProperties.consumptionRate
      TemperatureManager.drawFlames(self)
    end
    self.timer = 0.5
  end
  -- If the particle has a ParticleSystem, it is updated.
  if self.psystem then
    self.psystem:update(dt)
    self.psystem:setEmitterLifetime(self.integrity)
  end
end

return Particle
