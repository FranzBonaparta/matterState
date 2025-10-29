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

function Map:new()
  self.particles = {}
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
      elseif y < size - 4 and y > 40 and (x % 20 ==10 or x % 20 ==11 or x % 20 ==12) then
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
end

function Map:draw()
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      particle:draw()
    end
  end
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      particle.toolTip:draw()
    end
  end
end
function Map:mousepressed(mx,my,button)
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      particle:mousepressed(mx,my,button)
    end
  end
end
function Map:update(dt)
  local mx, my = love.mouse.getPosition()
  for _, line in ipairs(self.particles) do
    for _, particle in ipairs(line) do
      particle:update(dt, self.particles)
      -- It's only here that we check if a particle is hovered over, in order to activate its Tooltip.
      if particle:mouseIsHover(mx, my) then
        particle:initTooltip(self.particles)
      end
    end
  end
end

return Map
