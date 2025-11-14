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
local TileRenderer = require("UI.tileRenderer")
local Tooltip = require("libs.tooltip")

function Map:new(size)
  self.particles = {}
  self.width = size
  self.height = size
  TileRenderer.init()
  self.timer = 1         -- Limits updates to save calculations.
  self.isHovered = false -- Activate or desactivate the Tooltip
  self.toolTip = Tooltip("", self, 0.2)
  self.tooltipTarget = { 1, 1 }
  self.canvas = love.graphics.newCanvas()
  self.size = 8
  self:init(size)
  for _, line in ipairs(self.particles) do
    for _, p in ipairs(line) do
      p:setNeighbours(self)
    end
  end
  self:updateCanvas()
end

-- Here, we initialize the Tooltip
function Map:initTooltip(mx, my)
  local particle = self:getParticle(mx, my)
  if particle then
    -- text & tooltip construction
    local lines = {}
    local neighboursCount = particle:getNeighboursCount(self)
    table.insert(lines, string.format("index: %i", particle.index))
    table.insert(lines, string.format("[%i %i]", particle.x, particle.y))
    table.insert(lines, string.format("Avg Temp: %.1f°C", particle.temperature))
    table.insert(lines, string.format("NeighboursAmount: %i", neighboursCount))
    table.insert(lines,
      string.format("integrity: %i, density: %.2f", particle.integrity, particle.chemicalProperties.density))
    local stable = particle.stable and "stable" or "unstable"
    table.insert(lines, string.format("%s %s", particle.name, stable))
    table.insert(lines, string.format("%s", particle.chemicalProperties.state))
    local text = table.concat(lines, "\n")
    self.toolTip:setText(text)
  end
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
--Using the canvas allows us to reduce the CPU load with each draw!
--During a maximum fire spread, we go from 60% CPU usage to 12.3%!
function Map:updateCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      if particle.isBurning then
        local colors = { "red", "orange", "yellow" }
        local rand = math.random(3)
        TileRenderer.drawTile(colors[rand], particle.px, particle.py)
      else
        TileRenderer.drawTile(particle.name, particle.px, particle.py)
      end
      love.graphics.setColor(1, 1, 1)
    end
  end
  love.graphics.setCanvas()
end

-- This allow to change a particle after selecting a new sort of element in the palette
function Map:changeParticuleByColor(colors, x, y)
  local r, g, b = colors[1], colors[2], colors[3]
  local element = ParticlesData.getParticleByColors(r, g, b)
  if element and element.name then
    local p = self.particles[y][x]
    if p then
      p:changeName(element.name)
    end
  end
end

function Map:getParticle(mx, my)
  local x, y = math.floor(mx / self.size) , math.floor(my / self.size) 
  local particle = self.particles[y] and self.particles[y][x] or nil
  return particle
end

function Map:swapParticles(p1, p2)
  if p1.lastSwapIndex ~= p2.index and p1.index ~= p2.lastSwapIndex
  then
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
    --we update particles's neighbours lists
    if self.particles[y] and self.particles[ny] and self.particles[y][x] and self.particles[ny][nx] then
      self.particles[y][x] = p2
      self.particles[ny][nx] = p1
      p1:setNeighbours(self)
      p2:setNeighbours(self)
      local p1n = p1.neighbours
      local p2n = p2.neighbours
      --and we propagate the update from neighboring particles
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
end

-- We check if the mouse is hover the particle
function Map:mouseIsHover(mx, my)
  local isHover = false
  if mx >= self.size and mx <= (#self.particles[1] + 1) * self.size and
      my >= self.size and my <= (#self.particles + 1) * self.size then
    isHover = true
  end
  return isHover
end

function Map:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.canvas, 0, 0)
  self.toolTip:draw()
end

function Map:mousepressed(mx, my, button, colors)
  if colors then
    for _, line in ipairs(self.particles) do
      for _, particle in ipairs(line) do
        particle:mousepressed(mx, my, button)
        if particle.mouseIsHover and particle:mouseIsHover(mx, my) and button == 2 then
          self:changeParticuleByColor(colors, particle.x, particle.y)
          self:updateCanvas()
          return
        end
      end
    end
  end
end

function Map:update(dt)
  local mx, my = love.mouse.getPosition()
  local particle = self:getParticle(mx, my)
  self.timer = self.timer - dt
  -- It's only here that we check if a particle is hovered over, in order to activate the Tooltip.
  if particle then
    if self.tooltipTarget[1] ~= particle.x or self.tooltipTarget[2] ~= particle.y then
      self.tooltipTarget[1], self.tooltipTarget[2] = particle.x, particle.y
    end
  end
  if self.timer <= 0 then
    for _, line in ipairs(self.particles) do
      for _, p in ipairs(line) do
        p:update(dt, self)
       end
    end
    self:updateCanvas()
    if particle then
      self:initTooltip(mx, my)
    end
    self.timer = 0.5
  end
  self.toolTip:update(dt)
end

return Map
