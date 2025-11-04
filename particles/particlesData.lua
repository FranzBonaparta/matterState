--[[
    ParticlesData.lua
    Copyright (C) 2025 Jojopov

    This file is part of the MatterStates project.
    Licensed under the GNU GPL v3 (see LICENSE for details).

    ╔════════════════════════════════════════════════════════════════╗
    ║  Module : ParticlesData                                        ║
    ║  Description : Contains definitions and physical properties    ║
    ║                 of particles (density, temperature thresholds, ║
    ║                 flammability, etc.). Used by TemperatureManager║
    ║                 and related systems.                           ║
    ║  Author : Jojopov                                              ║
    ╚════════════════════════════════════════════════════════════════╝
]]

local ParticlesData = {}

ParticlesData.materials = {
  {
    name = "soil",
    temperature = 25,
    density = 1.5,
    conduction = 1.0,
    consumptionRate = 1,
    state = "granular",
    flammable = false,
    oxidant = false,
    ignitionPoint = 300,
    consumptionChild=nil,
    colors = { 102, 51, 0 }
  },
  {
    name = "oxygen",
    temperature = 10,
    density = 3,
    conduction = 0.03,
    consumptionRate = 1,
    state = "gas",
    flammable = false,
    oxidant = true,
    ignitionPoint = 300,
    consumptionChild="carbonDioxide",
    colors = { 153,255,255 }
  },
  {
    name = "carbonDioxide",
    temperature = 15,
    density = 1.87,
    conduction = 0.03,
    consumptionRate = 1,
    state = "gas",
    flammable = false,
    oxidant = false,
    ignitionPoint = 300,
    consumptionChild=nil,
    colors = { 80,120,130}
  },
  {
    name = "wood",
    temperature = 15,
    density = 0.5,
    conduction = 0.2,
    consumptionRate = 1,
    state = "solid",
    flammable = true,
    oxidant = false,
    ignitionPoint = 300,
    consumptionChild="charcoal",
    colors = { 204,102, 0 }
  },
  {
    name = "stone",
    temperature = 20,
    density = 2,
    conduction = 1.7,
    consumptionRate = 1,
    state = "solid",
    flammable = false,
    oxidant = false,
    ignitionPoint = 300,
    consumptionChild=nil,
    colors = { 160,160,160 }
  },
  {
    name = "charcoal",
    temperature = 15,
    density = 1.5,
    conduction = 0.055,
    state = "solid",
    consumptionRate = 2,
    flammable = true,
    oxidant = false,
    ignitionPoint = 280,
    consumptionChild="ashes",
    colors = { 0, 0, 0 }
  },
  {
    name = "ashes",
    temperature = 15,
    density = 1.5,
    conduction = 0.055,
    consumptionRate = 1,
    state = "granular",
    flammable = false,
    oxidant = false,
    ignitionPoint = 600,
    consumptionChild=nil,
    colors = { 220, 220, 220 }
  }
}

function ParticlesData.getParticleByName(name)
  for _, element in ipairs(ParticlesData.materials) do
    if element.name == name then
      return element
    end
  end
end
function ParticlesData.getColors(colors)
  for _, element in ipairs(ParticlesData.materials) do
    if element.colors then
      table.insert(colors,element.colors)
    end
  end
end

function ParticlesData.getParticleByColors(r,g,b)
   for _, element in ipairs(ParticlesData.materials) do
    local pr,pg,pb=love.math.colorFromBytes(element.colors[1],element.colors[2],element.colors[3])
    if pr==r and pg==g and pb==b then
      return element
    end
  end
end

return ParticlesData
