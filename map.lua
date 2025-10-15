local Object = require("libs.classic")
local Map = Object:extend()
local Tile = require("tile2")

function Map:new(x, y, amount)
  self.x = x
  self.y = y
  self.amount = amount --amount of tiles per line
  self.tiles = {}
  self.coolDown = 0.2
end

function Map:initTiles()
  for y = 0, self.amount - 1 do
    table.insert(self.tiles, {})
    for x = 0, self.amount - 1 do
      local size = 32
      local coordX, coordY = x * size, y * size
      local tile = Tile(coordX + self.x, coordY + self.y, size)
      if y == self.amount - 1 then
        if x % 4 == 0 or x % 3 == 0 then
          tile.materials:initElements("stone")
        else
          tile.materials:initElements("soil")
        end
      elseif y < self.amount - 1 and y > 10 and x % 5 == 0 then
        tile.materials:initElements("wood")
      elseif y == self.amount - 2 or y == self.amount - 3 and x % 5 > 0 then
        tile.materials:initElements("carbon")
      else
        tile.materials:initElements("oxygen")
      end
      table.insert(self.tiles[y + 1], tile)
    end
  end
  for _, line in ipairs(self.tiles) do
    for _, tile in ipairs(line) do
      tile:initTooltipText(self.tiles)
    end
  end
end

function Map:draw()
  for _, line in ipairs(self.tiles) do
    for _, tile in ipairs(line) do
      tile:draw()
    end
  end
  for _, line in ipairs(self.tiles) do
    for _, tile in ipairs(line) do
      if tile.toolTip.isVisible then
        tile.toolTip:draw()
        return
      end
    end
  end
end

function Map:mousepressed(mx, my, button)
  for _, line in ipairs(self.tiles) do
    for _, tile in ipairs(line) do
      tile:mousepressed(mx, my, button, self.tiles)
    end
  end
end

function Map:update(dt)
  local mx, my = love.mouse.getPosition()

  for _, line in ipairs(self.tiles) do
    for _, tile in ipairs(line) do
      tile:update(dt, self.tiles)
      if tile:mouseIsHover(mx, my) then
        tile:initTooltipText(self.tiles)
      end
        tile.materials:update(dt)
    end
  end
end

return Map
