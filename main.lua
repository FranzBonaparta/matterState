--[[
    main.lua
    Copyright (C) 2025 Jojopov

    This file is part of the MatterStates project.
    Licensed under the GNU GPL v3 (see LICENSE for details).

    MatterStates — where particles find their temperature.
╔════════════════════════════════════════════════════════════════╗
║  Entry Point : MatterStates                                    ║
║  Description : Initializes Löve2D, loads all components, and   ║
║                starts the main simulation loop.                ║
║                                                                ║
║  Author : Jojopov                                              ║
║  Creation : September 2025                                     ║
║                                                                ║
║  Notes :                                                       ║
║   - This file serves as the bootstrap for the engine.          ║
║   - It loads managers (Temperature, Density, etc.) and         ║
║     initializes the simulation environment.                    ║
╚════════════════════════════════════════════════════════════════╝
]]

local Map = require("UI.map")
local map = Map(80)
local Info = require("info")
local Palette = require("UI.palette")
local palette = nil
-- Function called only once at the beginning
function love.load()
    -- Initialization of resources (images, sounds, variables)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1) -- dark grey background
    palette = Palette(700, 10, 32)
    palette.buttons[1].onClick()
end

-- Function called at each frame, it updates the logic of the game
function love.update(dt)
    -- dt = delta time = time since last frame
    -- Used for fluid movements
    map:update(dt)
    if palette then
        palette:update(dt)
    end
end

-- Function called after each update to draw on screen
function love.draw()
    -- Everything that needs to be displayed passes here
    local startTime = love.timer.getTime()
    love.graphics.setColor(1, 1, 1)
    map:draw()
    if palette then
        palette:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
    local endTime = love.timer.getTime()
    local text = string.format("%.4f ms", (endTime - startTime) * 1000)
    love.graphics.printf(text, 900, 0, 200)
    Info.getDetail()
    love.graphics.setColor(1, 1, 1)
end

function love.mousepressed(mx, my, button)
    if palette then
        palette:mousepressed(mx, my, button)
        if palette.colorsSelected then
            map:mousepressed(mx, my, button, palette.colorsSelected)
        end
    end
end

-- Function called at each touch
function love.keypressed(key)
    -- Example: exit the game with Escape
    if key == "escape" then
        love.event.quit()
    end
end
