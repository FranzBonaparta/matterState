--[[
    Tooltip.lua
    Copyright (C) 2025 Jojopov

    This file is part of the MatterStates project.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License published by the Free Software Foundation,
either version 3 of the license, or (at your option) any later version.

This program is distributed in the hope that it will be useful,

but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for details.

You should have received a copy of the GNU General Public License
with this program. If not, see <https://www.gnu.org/licenses/>.

╔════════════════════════════════════════════════════════════════╗
║  Component : Tooltip                                           ║
║  Description : Displays a tooltip (text) when hovering over    ║
║                  an interactive element with the mouse.        ║
║  Author : Jojopov                                              ║
║  Creation : April 2025                                         ║
║  Use :                                                         ║
║     local Tooltip = require("ui.Tooltip")                      ║
║     local tip = Tooltip("My text", button)                     ║
║    or local tip= Tooltip("My text", button, delay, "left")     ║
║     tip:update(dt); tip:draw()                                 ║
╚════════════════════════════════════════════════════════════════╝
]]
local Object = require("libs.classic")
local Tooltip = Object:extend()

function Tooltip:new(text, target, delay, position)
    self.text = text                  -- Tooltip text content
    self.target = target              -- Tooltip target
    self.delay = delay or 0.5         -- Delay (in seconds) before the display is activated
    self.position = position or "top" -- left, right, top or bottom
    self.hoverTime = 0                -- mouse hover time over the target
    self.isVisible = false
end

-- Here, we define the content of the tooltip's text field
function Tooltip:setText(text)
    self.text = text
end

-- Here, we define the display of the Tooltip
function Tooltip:draw()
    --[[ Since this function is called on every frame,
we first check that the Tooltip is visible ]]
    if self.isVisible then
        love.graphics.setColor(1, 1, 1)
        local mx, my = love.mouse.getPosition()
        local tooltipX, tooltipY = mx + 10, my + 10
        -- we call the default Löve's font
        local font = love.graphics.getFont()
        local boxWidth = 250
        local _, wrappedText = font:getWrap(self.text, boxWidth - 16) --return a table of line
        local lineHeight = font:getHeight()
        -- make the heigh flexible
        local lineCount = #wrappedText
        local boxHeight = (lineHeight * lineCount) + 16 --+padding

        love.graphics.rectangle("fill", tooltipX, tooltipY, boxWidth, boxHeight, 6, 6)
        -- clear border
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle("line", tooltipX, tooltipY, boxWidth, boxHeight, 6, 6)
        -- text
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.text, tooltipX + 8, tooltipY + 8, boxWidth - 16)
        -- reset color to white
        love.graphics.setColor(1, 1, 1)
    end
end

--[[
The tooltip is displayed via the update.

It's best to wait a while before
activating the display, to avoid it reappearing every time
 the mouse moves over a pixel in a short period of time! ]]
function Tooltip:update(dt)
    local mx, my = love.mouse.getPosition()
    -- If the mouse hovers over the target for a certain amount of time: the Tooltip is displayed
    if self.target:mouseIsHover(mx, my) then
        self.hoverTime = self.hoverTime + dt
        if self.hoverTime >= self.delay then
            self.isVisible = true
        end
        -- If the mouse is not hovering over the target, we ensure the Tooltip is hidden.
    else
        self.hoverTime = 0
        self.isVisible = false
    end
end

return Tooltip
