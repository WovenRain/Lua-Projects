--Main Love file,
--Manages overall control
require("ChooseAI")
require("Menu")

require("gameGUI")

WindowState = 0

function love.load()
    Menu.load()
    ChooseAI.load()
end

--bit heavy handed atm
--TODO change this into a more gentle exit, ask the player if they're sure
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        if WindowState == 0 then
            love.event.quit()
        else
            changeGametype(0)
        end
    end
end

function love.update(dt)

    if WindowState == 0 then
    elseif WindowState == 1 or
            WindowState == 2 then
        gameGUI:update(dt)
    end
end

function love.draw()
    if WindowState == 0 then
        Menu.draw()
    elseif WindowState == 1 or
            WindowState == 2 then
        gameGUI:draw()
    elseif WindowState == 100 then
        ChooseAI:draw()
    end
end

--called from Menu
--[[
    0 : Main menu
    1 : play vs picks_1
    2 : play vs The Fool

    100: AI menu
]]
function changeGametype(x)
    if x == 1 then
        gameGUI:load("Player", "gui", "Plays_1", "1")
    elseif x == 2 then
        gameGUI:load("Player", "gui", "The Fool", "random")
    end
    WindowState = x
end