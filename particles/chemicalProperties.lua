local Object = require("libs.classic")
local ChemicalProperties = Object:extend()
local ParticlesData = require("particles.particlesData")

function ChemicalProperties:new(name)
  self.state = "gas"   --or "liquid" , "solid"
  self.density = 5
  self.conduction = 0
  self.isFlammable = false
  self.isOxidant = false --comburant
  self.ignitionPoint = 300
  self.maxTemperature = self.isFlammable and 1000 or 600

  self:init(name)
end

function ChemicalProperties:init(name)
  local newParticle = ParticlesData.getParticleByName(name)
  if newParticle then
    self.state = newParticle.state
    self.isFlammable = newParticle.flammable
    self.isOxidant = newParticle.oxidant
    self.ignitionPoint = newParticle.ignitionPoint
    self.density = newParticle.density
    self.conduction = newParticle.conduction
  else
    print(string.format("'%s' doesn't exist on particles's table!", name))
  end
end

return ChemicalProperties
