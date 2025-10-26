local TemperatureManager = {}

function TemperatureManager.canBurn(particle, map)
  local bool = false
  local neighbours = particle:getNeighbours(map)
  if #neighbours == 0 then return end
  for _, neighbour in ipairs(neighbours) do
    if neighbour.isOxidant then
        return particle.temperature >= (particle.ignitionPoint-50) and particle.isFlammable
    end
  end
  return false
end

function TemperatureManager.propagateTemperature(particle, map)
  local neighbours = particle:getNeighbours(map)
  if particle.isBurning and particle.temperature <= particle.maxTemperature then
    particle.temperature = math.min(particle.temperature + 20, particle.maxTemperature)
  end
  if #neighbours == 0 then return end
  local sumTemp=0
  for _, neighbour in ipairs(neighbours) do
    local diff = neighbour.temperature - particle.temperature
    sumTemp=sumTemp+diff
    if neighbour.isBurning and particle.isFlammable and particle.temperature >= particle.ignitionPoint - 50 then
      particle:ignite()
      break
    elseif particle.isBurning then
      neighbour.temperature=neighbour.temperature+diff*0.5*neighbour.conduction
    elseif diff >0 then
      particle.temperature = particle.temperature + (diff*0.5 * particle.conduction)
    end
  end
end

function TemperatureManager.drawFlames(particle)
  if particle.isBurning then
    local rand = math.random(1, 3)
    local colors = { { 255, 0, 0 }, { 255, 128, 0 }, { 255, 255, 0 } }
    particle.color = colors[rand]
  end
end

return TemperatureManager
