--Main Love file,
--Manages overall control
require("GUIPrototype")
require("gameloop")

function love.load()
    gameloop:initialisation("Player", "gui", "Enemy", "random")
    GUIPrototype:load()
end

function love.update(dt)
    GUIPrototype:update(dt)
end

function love.draw()
    GUIPrototype:draw()
end