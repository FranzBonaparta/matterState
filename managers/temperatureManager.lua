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

function TemperatureManager.propagateTemperature(particle, map, dt)
  local delta = math.floor(dt * 1000)
  local neighbours = particle:getNeighbours(map)
  if not particle.chemicalProperties or #neighbours == 0 then return end

  if particle.isBurning and particle.temperature <= particle.chemicalProperties.maxTemperature then
    particle.temperature = math.min(particle.temperature + delta, particle.chemicalProperties.maxTemperature)
  end

  local hasBurn = false
  for _, neighbour in ipairs(neighbours) do
    if neighbour.isBurning then
      hasBurn = true
      break
    end
  end

  for _, neighbour in ipairs(neighbours) do
    local diff = neighbour.temperature - particle.temperature
    --ignition
    if neighbour.isBurning and particle.chemicalProperties.isFlammable and particle.temperature >= particle.chemicalProperties.ignitionPoint - 50 then
      particle:ignite()
      break
    end
    --propagate temperature if neighbour is colder
    if particle.isBurning and diff < 1 then
      local convectionFactor = (neighbour.y < particle.y) and 2 or 1.5
      neighbour:changeTemperature(neighbour.temperature -
        diff * 0.5 * neighbour.chemicalProperties.conduction * convectionFactor)
      --else classical diffusion on self (if not burning)
    elseif not particle.isBurning and diff > 1 then
      particle:changeTemperature(particle.temperature +
        diff * 0.5 * neighbour.chemicalProperties.conduction)
      --elseif no source of heat, decrease the temperature
    elseif particle.name == "ashes" or (not particle.isBurning and not hasBurn and diff < 1) then
      particle:changeTemperature(math.max(particle.startTemperature, particle.temperature - (delta / 4)))
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
  love.graphics.push("all") -- Save all the state (blendmode, canvas, etc)
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.setBlendMode("alpha", "premultiplied") -- important
  love.graphics.setColor(125 / 255, 125 / 255, 125 / 255, 0.7)
  love.graphics.circle("fill", 0, 0, size)
  --love.graphics.rectangle("fill", 0, 0, size, size)
  love.graphics.pop()
  local psystem = love.graphics.newParticleSystem(canvas, 32)
  psystem:setParticleLifetime(2, 5) -- Particles live at least 2s and at most 5s.
  psystem:setEmitterLifetime(particle.integrity)
  psystem:setEmissionRate(5)
  psystem:setSizes(1, 2, 4) -- to test
  psystem:setSizeVariation(1)
  --ParticleSystem:setLinearAcceleration( xmin, ymin, xmax, ymax )
  psystem:setLinearAcceleration(-size - 5, -20, size + 5, 0)                                  -- Random movement in all directions.
  psystem:setColors(125 / 255, 125 / 255, 125 / 255, 0.3, 125 / 255, 125 / 255, 125 / 255, 0) -- Fade to transparency.
  particle.psystem = psystem
end

return TemperatureManager
