local TILE_SIZE=8
local tileCanvases={}
local TileRenderer={}

function TileRenderer.init()
local colors={
  { 102, 51, 0 },{ 153,255,255 },{ 80,120,130},{ 204,102, 0 },
  { 160,160,160 },{ 0, 0, 0 },{ 220, 220, 220 },
  { 255, 0, 0 }, { 255, 128, 0 }, { 255, 255, 0 }
}
local matters={
  "soil","oxygen","carbonDioxide","wood",
  "stone","charcoal","ashes","red","orange","yellow"
}
for i=1,#colors do
  local canvas=love.graphics.newCanvas(TILE_SIZE,TILE_SIZE)
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  local color=colors[i]
  local r,g,b=love.math.colorFromBytes(color[1],color[2],color[3])
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("fill",0,0,TILE_SIZE,TILE_SIZE)
  love.graphics.setCanvas()
  tileCanvases[matters[i]]=canvas
end

end
function TileRenderer.drawTile(tileType, x, y)
    local canvas = tileCanvases[tileType]
    if canvas then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(canvas, x, y)
    else
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("?", x, y)
    end
      love.graphics.setColor(1,1,1)

end

return TileRenderer