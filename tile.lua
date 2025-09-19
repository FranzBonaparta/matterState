local Object = require("libs.classic")
local Tooltip = require("libs.tooltip")
local Tile = Object:extend()
local Element = require("material.material")

function Tile:new(x, y, size)
    self.x = x
    self.y = y
    self.size = size
    self.element = nil
    self.toolTip = Tooltip("", self, 0.2)
    self.borderColor = { 255, 0, 0 }
    self.coolDown = 1
end

function Tile:initTooltipText()
    self.toolTip.text = ""
    local a, b = self:getCoords()
    -- construction du texte du tooltip
    local lines = {}
    table.insert(lines, string.format("[%i %i]", a, b))
    --table.insert(lines, string.format("%i materials", total))
    table.insert(lines, string.format("Avg Temp: %.2f°C", self.element.temperature))
    table.insert(lines, self.element.name)
    table.insert(lines,self.element.isBurning==true and "burn" or "stable")
    self.toolTip.text = table.concat(lines, "\n")
end

function Tile:initElements(name)
    self.element = Element(self.x, self.y, self.size, name)
end

function Tile:draw()
    self.element:draw()
    local r, g, b = self.borderColor[1] / 255, self.borderColor[2] / 255, self.borderColor[3] / 255

    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)

    love.graphics.setColor(1, 1, 1)
end

function Tile:mouseIsHover(mx, my)
    local isHover = false
    if mx >= self.x and mx <= self.x + self.size and
        my >= self.y and my <= self.y + self.size then
        isHover = true
    end
    return isHover
end

function Tile:getCoords()
    return self.x / 32, self.y / 32
end

function Tile:getNeighbours(map)
    local neighbours = {}
    for y, line in ipairs(map) do
        for x, tile in ipairs(line) do
            if tile ~= self then
                local dx = math.abs(tile.x - self.x)
                local dy = math.abs(tile.y - self.y)
                if dx <= self.size and dy <= self.size then
                    table.insert(neighbours, tile)
                end
            end
        end
    end
    return neighbours
end

function Tile:canBurn(neighbours)
    local oxidants = {}
    for index, tile in ipairs(neighbours) do
        if tile.element.isOxidant then
            table.insert(oxidants, tile)
        end
    end
    if self.element:canBurn() and #oxidants > 0 and not self.element.isBurning then
        self.element:ignite()
        self:initTooltipText()
    end
end

function Tile:getBurningNeighbours(neighbours)
    local burnings = {}
    for _, neighbour in ipairs(neighbours) do
        if neighbour.element.isBurning then
            table.insert(burnings, neighbour)
        end
    end
    return burnings
end
function Tile:didBurn()
    if not self.element.isBurning and self.element:canBurn() then
        self.element.isBurning=true
    end
end
function Tile:update(dt, neighbours)
    self.toolTip:update(dt)
    self.coolDown = self.coolDown - dt
    if self.coolDown <= 0 and #neighbours > 1 then
        --print(#neighbours.." neighbours")
        local burnings = self:getBurningNeighbours(neighbours)
        local variation = 0
        if self.element.isBurning then
            if #burnings == 0 then
                variation =  (self.element.temperature - self.element.ignitionPoint)/self.element.ignitionPoint
                self.element.temperature = self.element.temperature + variation
            else
                for _, tile in ipairs(burnings) do
                    local element = tile.element
                    variation = variation + ( (element.temperature - element.ignitionPoint)/element.ignitionPoint)
                end
                variation = (variation / #burnings) +
                ((self.element.temperature - self.element.ignitionPoint)/self.element.ignitionPoint)
                self.element.temperature = self.element.temperature + variation/2
            end
        else -- not self.element.isBurning
            if #burnings == 0 then
                for _, tile in ipairs(neighbours) do
                    local element = tile.element

                    variation = variation + element.temperature
                end
                self.element.temperature = (self.element.temperature + variation) / (#neighbours+1)
            else
                for _, tile in ipairs(burnings) do
                    local element = tile.element
                    variation = variation + ((element.temperature - element.ignitionPoint)/element.ignitionPoint  )
                end
                variation = variation / #burnings
                self.element.temperature = self.element.temperature + variation
            end
        end
        self:didBurn()
        self:initTooltipText()
        self.coolDown = 0.5
    end
end

function Tile:mousepressed(mx, my, button)
    if self:mouseIsHover(mx, my) and button == 1 then
        self.element:ignite()
        self:initTooltipText()
    end
end

return Tile
