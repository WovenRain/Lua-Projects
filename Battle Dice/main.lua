--Main Love file,
--Manages overall control
require("GUIPrototype")
require("gameGUI")
require("gameloop")

function love.load()
    --GUIPrototype:load()
    gameGUI:load()
end

function love.update(dt)
    --GUIPrototype:update(dt)
    gameGUI:update(dt)
end

function love.draw()
    --GUIPrototype:draw()
    gameGUI:draw()
end