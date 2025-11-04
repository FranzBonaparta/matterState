local Object=require("libs.classic")
local Palette=Object:extend()
local ParticlesData=require("particles.particlesData")
local Button=require("libs.button")


function Palette:new(x,y,size)
  self.x=x
  self.y=y
  self.size=size
  self.colors={}
  self.colorsSelected=nil
  ParticlesData.getColors(self.colors)
  self.buttons={}
  self:initButtons()
end

function Palette:initButtons()
  for i, color in ipairs(self.colors) do
    local rest=i%2 --rest=1 or 0
    --we want to have two columns of buttons
    local x=self.x+(rest*self.size)
    local y= self.y+(math.floor(i/2)*self.size) 
    local button=Button(x,y,self.size,self.size)
    button:setImmediate()
    local r,g,b,a=color[1],color[2],color[3],0
    button:setBackgroundColor(r,g,b,a)
    button:setOnClick(function()self.colorsSelected=button.backgroundColor end)
    table.insert(self.buttons,button)
  end
end

function Palette:draw()
  for _, button in ipairs(self.buttons) do
    button:draw()
  end
  if self.colorsSelected then
    local r,g,b=self.colorsSelected[1],self.colorsSelected[2],self.colorsSelected[3]
    love.graphics.setColor(r,g,b)
    love.graphics.rectangle("fill",self.x,self.y+(((#self.colors/2)+1)*self.size),self.size,self.size)
  end
  love.graphics.setColor(1,1,1)
end

function Palette:mousepressed(mx,my,button)
  for _, value in ipairs(self.buttons) do
    value:mousepressed(mx,my,button)
  end
end

return Palette