--[[
    Map.lua
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
║  Component : Map                                               ║
║  Description : it's a two dimension array of Particles         ║
║  Author : Jojopov                                              ║
║  Creation : September 2025                                     ║
║  Use :                                                         ║
║     local Map = require("map")                                 ║
║     local map = Map()                                          ║
║    map:init(80); map:update(dt); map:draw()                    ║
╚════════════════════════════════════════════════════════════════╝
]]
local Object = require("libs.classic")
local Particle = require("particles.particle")
local Map = Object:extend()
local ParticlesData = require("particles.particlesData")
local TileRenderer = require("tileRenderer")

function Map:new(size)
  self.particles = {}
  self.width = size
  self.height = size
  TileRenderer.init()
  self.timer = 1 -- Limits updates to save calculations.
  self.canvas = love.graphics.newCanvas()
  -- Here, we hard-define the logic for creating our map. The values ​​are chosen purely for convenience.
  for y = 1, self.height do
    for x = 1, self.width do
      local index = (y - 1) * self.width + x
      local p = Particle(x, y)
      local name = ""
      if y >= size - 4 then
        if x % 16 == 10 or x % 16 == 11 or x % 16 == 12 or x % 16 == 13 then
          name = "stone"
        else
          name = "soil"
        end
      elseif y < size - 4 and y > 40 and (x % 20 == 10 or x % 20 == 11 or x % 20 == 12) then
        name = "wood"
      elseif (y <= size - 4 and y >= size - 12) and x % 20 ~= 10 then
        name = "carbonDioxide"
      else
        name = "oxygen"
      end

      p:changeName(name)
      if p.chemicalProperties.state == "solid" then
        p.stable = true
      end
      self.particles[index] = p
    end
  end
  for _, p in ipairs(self.particles) do
    p:setNeighbours(self)
  end
  self:updateCanvas()
end

-- Here, we hard-define the logic for creating our map. The values ​​are chosen purely for convenience.
function Map:init(size)
  self.particles = {}
  for y = 1, size, 1 do
    table.insert(self.particles, {})
    for x = 1, size, 1 do
      local particle = Particle(x, y)
      local name = ""
      if y >= size - 4 then
        if x % 16 == 10 or x % 16 == 11 or x % 16 == 12 or x % 16 == 13 then
          name = "stone"
        else
          name = "soil"
        end
      elseif y < size - 4 and y > 40 and (x % 20 == 10 or x % 20 == 11 or x % 20 == 12) then
        name = "wood"
      elseif (y <= size - 4 and y >= size - 12) and x % 20 ~= 10 then
        name = "carbonDioxide"
      else
        name = "oxygen"
      end
      particle:changeName(name)
      table.insert(self.particles[y], particle)
    end
  end
  for _, particle in ipairs(self.particles[#self.particles]) do
    if particle.chemicalProperties.state == "solid" then
      particle.stable = true
    end
  end
end

function Map:updateCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()

  for _, particle in ipairs(self.particles) do
    if particle.isBurning then
      local colors = { "red", "orange", "yellow" }
      local rand = math.random(3)
      TileRenderer.drawTile(colors[rand], particle.px, particle.py)
    else
      TileRenderer.drawTile(particle.name, particle.px, particle.py)
    end
    love.graphics.setColor(1, 1, 1)
  end
  love.graphics.setCanvas()
end

function Map:getIndex(x, y)
  if x < 1 or x > self.width or y < 1 or y > self.height then
    return nil
  end
  return (y - 1) * self.width + x
end

function Map:getParticle(x, y)
  local idx = self:getIndex(x, y)
  return idx and self.particles[idx] or nil
end

-- This allow to change a particle after selecting a new sort of element in the palette
function Map:changeParticuleByColor(colors, x, y)
  local r, g, b = colors[1], colors[2], colors[3]
  local element = ParticlesData.getParticleByColors(r, g, b)
  if element and element.name then
    local p = self:getParticle(x, y)
    if p then
      p:changeName(element.name)
    end
  end
end

function Map:swapParticles(p1, p2)
  if p1.lastSwapIndex ~= p2.index and p1.index ~= p2.lastSwapIndex
  then
    local i1 = self:getIndex(p1.x, p1.y)
    local i2 = self:getIndex(p2.x, p2.y)
    if not i1 or not i2 then return end
    self.particles[i1], self.particles[i2] = self.particles[i2], self.particles[i1]

    local x, y = p1.x, p1.y
    local nx, ny = p2.x, p2.y
    local px, py = p1.px, p1.py
    local npx, npy = p2.px, p2.py
    p1.lastSwapIndex = p2.index
    p2.lastSwapIndex = p1.index
    p1.px, p1.py = npx, npy
    p1.x, p1.y = nx, ny
    p2.px, p2.py = px, py
    p2.x, p2.y = x, y
    p1:setNeighbours(self)
    p2:setNeighbours(self)
    local p1n = p1.neighbours
    local p2n = p2.neighbours
    for _, n in ipairs(p1n) do
      local neighbour = n.value
      if neighbour.index ~= p2.index then
        neighbour:setNeighbours(self)
      end
    end
    for _, n in ipairs(p2n) do
      local neighbour = n.value
      if neighbour.index ~= p1.index then
        neighbour:setNeighbours(self)
      end
    end
  end
end

function Map:draw()
  --[[for _, particle in ipairs(self.particles) do
    particle:draw()
  end]]
  love.graphics.setColor(1, 1, 1)

  love.graphics.draw(self.canvas, 0, 0)
   for _, particle in ipairs(self.particles) do
    particle.toolTip:draw()
     --[[  if particle.psystem then
    love.graphics.draw(particle.psystem, particle.px, particle.py)
  end]]
  end
end

function Map:mousepressed(mx, my, button, colors)
  if colors then
    for y, particle in ipairs(self.particles) do
      particle:mousepressed(mx, my, button)
      if particle.mouseIsHover and particle:mouseIsHover(mx, my) and button == 2 then
        self:changeParticuleByColor(colors, particle.x, particle.y)
        self:updateCanvas()
        return
      end
    end
  end
end

function Map:update(dt)
  local mx, my = love.mouse.getPosition()
  self.timer = self.timer - dt
  if self.timer <= 0 then
    for _, particle in ipairs(self.particles) do
      
      particle:update(dt, self)
      -- It's only here that we check if a particle is hovered over, in order to activate its Tooltip.
      if particle:mouseIsHover(mx, my) then
        particle:initTooltip(self)
      end
    end
    self:updateCanvas()
    self.timer = 0.5
  end
  for _, particle in ipairs(self.particles) do
    particle.toolTip:update(dt)
  end
end

return Map
