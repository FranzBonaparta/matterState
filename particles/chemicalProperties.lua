--[[
    chemicalProperties.lua
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
║  Component : ChemicalProperties                                         ║
║  Description : Allows the storage, management and distribution          ║
║                of the chemical properties of a particle.                ║
║  Author : Jojopov                                                       ║
║  Creation : October 2025                                                ║
║  Use :                                                                  ║
║     local ChemicalProperties = require("particles.chemicalProperties")  ║                    ║
║     local prop = ChemicalProperties("soil")                             ║
║     prop:init("charcoal")                                               ║
╚═════════════════════════════════════════════════════════════════════════╝
]]
local Object = require("libs.classic")
local ChemicalProperties = Object:extend()
local ParticlesData = require("particles.particlesData")

function ChemicalProperties:new(name)
  self.state = "gas"   --or "liquid" , "solid"
  self.density = 5
  self.conduction = 0   --thermal conduction
  self.consumptionRate=1  --speed of consumption by fire
  self.isFlammable = false
  self.isOxidant = false --comburant
  self.ignitionPoint = 300
  self.maxTemperature = self.isFlammable and 1000 or 600
  self.consumptionChild=""  --  the particle transformation after consumption by fire

  self:init(name)
end

-- This function allows you to retrieve all the relevant fields from particlesData.lua
function ChemicalProperties:init(name)
  local newParticle = ParticlesData.getParticleByName(name)
  if newParticle then
    self.state = newParticle.state
    self.isFlammable = newParticle.flammable
    self.isOxidant = newParticle.oxidant
    self.ignitionPoint = newParticle.ignitionPoint
    self.density = newParticle.density
    self.conduction = newParticle.conduction
    self.consumptionRate= newParticle.consumptionRate
    self.consumptionChild=newParticle.consumptionChild
  else
    print(string.format("'%s' doesn't exist on particles's table!", name))
  end
end

return ChemicalProperties
