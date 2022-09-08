--Main Love file,
--Manages overall control
require("ChooseAI")
require("Menu")
require("graphics")
require("music")
require("settingsMenu")

require("gameGUI")

WindowState = 0

function love.load()
    graphics:load()
    music:start()
    
    Menu.load()
    ChooseAI.load()
    settingsMenu:load()
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
    elseif WindowState > 0 and WindowState < 10 then
        gameGUI:update(dt)
    end
end

function love.draw()
    music:update()
    if WindowState == 0 then
        Menu.draw()
    elseif WindowState > 0 and WindowState < 10 then
        gameGUI:draw()
    elseif WindowState == -1 then
        ChooseAI:draw()
    elseif WindowState == -2 then
        settingsMenu:draw()
    end
end

--called from Menu
--[[
    -2: settingsMenu
    -1: AI menu
    0 : Main menu

    1 : play vs picks_1
    2 : play vs The Fool
    3 : play vs BasicAI / Emperor

]]
Player_plate = "soldierB"
function changeGametype(x)
    if x == 1 then
        gameGUI:load("Player", "gui", Player_plate, "Plays_1", "1", "plays_1")
        music:playNew("Plays_1")
    elseif x == 2 then
        gameGUI:load("Player", "gui", Player_plate, "The Fool", "random", "fool")
        music:playNew("The Fool")
    elseif x == 3 then
        gameGUI:load("Player", "gui", Player_plate, "Emperor", "basic", "soldierA")
        music:playNew("Emperor")
    elseif x == 0 and WindowState > 0 then
        music:playNew("theme")
    end
    WindowState = x
end