local ParticlesData = {}

ParticlesData.materials = {
  {
    name = "soil",
    temperature = 25,
    density = 1.5,
    conduction = 1.0,
    consumptionRate = 1,
    state = "solid",
    flammable = false,
    oxidant = false,
    ignitionPoint = 300,
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
    colors = { 204, 255, 255 }
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
    colors = { 224, 224, 224 }
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
    colors = { 153, 76, 0 }
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
    colors = { 96, 96, 96 }
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
    colors = { 0, 0, 0 }
  },
  {
    name = "ashes",
    temperature = 15,
    density = 1.5,
    conduction = 0.055,
    consumptionRate = 1,
    state = "solid",
    flammable = false,
    oxidant = false,
    ignitionPoint = 600,
    colors = { 224, 224, 224 }
  }
}

function ParticlesData.getParticleByName(name)
  for _, element in ipairs(ParticlesData.materials) do
    if element.name == name then
      return element
    end
  end
end

return ParticlesData
