local TemperatureManager = {}

function TemperatureManager.canBurn(particle, map)
  local neighbours = particle:getNeighbours(map)
  if #neighbours == 0 then return end
  for _, neighbour in ipairs(neighbours) do
    if neighbour.chemicalProperties and neighbour.chemicalProperties.isOxidant then
      return particle.temperature >= (particle.chemicalProperties.ignitionPoint - 50) and
          particle.chemicalProperties.isFlammable
    end
  end
  return false
end

function TemperatureManager.propagateTemperature(particle, map)
  local neighbours = particle:getNeighbours(map)
  if particle.chemicalProperties then
    if particle.isBurning and particle.temperature <= particle.chemicalProperties.maxTemperature then
      particle.temperature = math.min(particle.temperature + 20, particle.chemicalProperties.maxTemperature)
      -- elseif particle.chemicalProperties.isFlammable==false and particle.temperature > particle.startTemperature then
      --  particle.temperature = math.max(particle.temperature - 10, particle.startTemperature)
    end
    if particle.chemicalProperties.isFlammable == false and particle.temperature > particle.startTemperature then
      particle.temperature = math.max(particle.temperature - 1, particle.startTemperature)
    end
    if #neighbours == 0 then return end
    local sumTemp = 0
    for _, neighbour in ipairs(neighbours) do
      local diff = neighbour.temperature - particle.temperature
      sumTemp = sumTemp + diff
      if neighbour.isBurning and particle.chemicalProperties.isFlammable and particle.temperature >= particle.chemicalProperties.ignitionPoint - 50 then
        particle:ignite()
        break
      elseif particle.isBurning then
        local convectionFactor = 1.0
        if neighbour.y < particle.y then
          convectionFactor = 2.0 -- chauffe 2x plus vers le haut
        end
        neighbour.temperature = neighbour.temperature +
        math.abs(diff) * 0.5 * neighbour.chemicalProperties.conduction * convectionFactor
      elseif diff > 0 then
        particle.temperature = particle.temperature + (diff * 0.5 * particle.chemicalProperties.conduction)
      end
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

function TemperatureManager.makeSmoke(particle)
  local size = particle.size / 2
  local canvas = love.graphics.newCanvas(size, size, { format = "rgba8" })
  love.graphics.push("all")  -- Sauvegarde tout l’état (blendmode, canvas, etc)
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0, 0, 0,0)
  love.graphics.setBlendMode("alpha", "premultiplied")     -- important
  love.graphics.setColor(125 / 255, 125/ 255, 125 / 255,0.5)

  love.graphics.rectangle("fill", 0,0, size, size)
  love.graphics.pop()
  local psystem = love.graphics.newParticleSystem(canvas, 32)
  psystem:setParticleLifetime(2, 5) -- Particles live at least 2s and at most 5s.
  psystem:setEmitterLifetime(particle.integrity)
  psystem:setEmissionRate(5)
  psystem:setSizes(1, 2, 4) -- à tester
  psystem:setSizeVariation(1)
   --ParticleSystem:setLinearAcceleration( xmin, ymin, xmax, ymax )
  psystem:setLinearAcceleration(-size-5, -20, size+5, 0) -- Random movement in all directions.
  psystem:setColors(125 / 255, 125/ 255, 125 / 255,0.3,125 / 255, 125/ 255, 125 / 255, 0)   -- Fade to transparency.
  particle.psystem = psystem
end

return TemperatureManager
