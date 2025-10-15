local Object = require("libs.classic")
local Tooltip = require("libs.tooltip")
local Tile = Object:extend()
local MaterialsTable = require("material.materialsTable")
function Tile:new(x, y, size)
    self.x = x
    self.y = y
    self.size = size
    self.materials = MaterialsTable(self.x, self.y, self.size)
    self.toolTip = Tooltip("", self, 0.2)
    self.borderColor = { 255, 0, 0 }
    self.neighboursCount = 0
end

function Tile:initTooltipText(map)
    local a, b = self:getCoords()

    local counts = {}
    local total = 0
    local tempSum = 0
    -- average temperature
    local _, neighboursCount = self:getNeighbours(map)
    self.neighboursCount = neighboursCount
    -- text & tooltip construction
    local lines = {}
    table.insert(lines, string.format("[%i %i]", a, b))

    for _, row in ipairs(self.materials.elements) do
        for _, material in ipairs(row) do
            total = total + 1
            tempSum = tempSum + material.temperature

            -- names count
            counts[material.name] = (counts[material.name] or 0) + 1
        end
    end
    local avgTemp = total > 0 and (tempSum / total) or 0
    table.insert(lines, string.format("%i materials", total))
    table.insert(lines, string.format("Avg Temp: %.1f°C", avgTemp))
    table.insert(lines, string.format("NeighboursAmount: %i", self.neighboursCount))
    table.insert(lines,
        string.format("[%.1f°C,%.1f°C,%.1f°C,%.1f°C]", self.materials.elements[1][1].temperature,
            self.materials.elements[1][2].temperature, self.materials.elements[1][3].temperature,
            self.materials.elements[1][4].temperature))
    table.insert(lines,
        string.format("[%.1f°C,%.1f°C,%.1f°C,%.1f°C]", self.materials.elements[2][1].temperature,
            self.materials.elements[2][2].temperature, self.materials.elements[2][3].temperature,
            self.materials.elements[2][4].temperature))
    table.insert(lines,
        string.format("[%.1f°C,%.1f°C,%.1f°C,%.1f°C]", self.materials.elements[3][1].temperature,
            self.materials.elements[3][2].temperature, self.materials.elements[3][3].temperature,
            self.materials.elements[3][4].temperature))
    table.insert(lines,
        string.format("[%.1f°C,%.1f°C,%.1f°C,%.1f°C]", self.materials.elements[4][1].temperature,
            self.materials.elements[4][2].temperature, self.materials.elements[4][3].temperature,
            self.materials.elements[4][4].temperature))
    -- adding percentages
    for name, count in pairs(counts) do
        local percent = (count / total) * 100
        table.insert(lines, string.format("%s: %.1f%%", name, percent))
    end

    self.toolTip.text = table.concat(lines, "\n")
end

function Tile:getCoords()
    return self.x / 32, self.y / 32
end

function Tile:mouseIsHover(mx, my)
    local isHover = false
    if mx >= self.x and mx <= self.x + self.size and
        my >= self.y and my <= self.y + self.size then
        isHover = true
    end
    return isHover
end

function Tile:getNeighbours(map)
    local neighbours = {}
    local coordX, coordY = self:getCoords()
    --get map size
    local mapHeight, mapWidth = #map, #map[1]

    local dx = { coordX - 1, coordX, coordX + 1, coordX }
    local dy = { coordY, coordY - 1, coordY, coordY + 1 }
    local count = 0
    for i = 1, 4, 1 do
        if dy[i] >= 0 and dx[i] >= 0 and dy[i] < mapHeight and dx[i] < mapWidth then
            local tile = map[dy[i] + 1][dx[i] + 1]
            table.insert(neighbours, tile)
            count = count + 1
        else
            table.insert(neighbours, {})
        end
    end
    return neighbours, count
end

function Tile:draw()
    self.materials:draw()
    local r, g, b = self.borderColor[1] / 255, self.borderColor[2] / 255, self.borderColor[3] / 255

    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)

    love.graphics.setColor(1, 1, 1)
end

function Tile:update(dt, tiles)
    self.toolTip:update(dt)
    self.materials:update(dt)

end

function Tile:mousepressed(mx, my, button, tiles)
    if self:mouseIsHover(mx, my) and button == 1 then
        self.materials:ignite()
        self:initTooltipText(tiles)
    end
end

return Tile
