require("player")
require("player2")
require("ball")
require("ai")
require("score")
require("menu")
require("powerup")

gameType = 0

function love.load()
	Menu.load()
	Player:load()
	Player2:load()
	Ball:load()
	AI:load()
	Powerup:load()
	Score:load()
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		changeGametype(0)
	end


	if gameType == 1 then
		Player:update(dt)
		Ball:update(dt)
		AI:update(dt)
		Score:update(dt)
		Powerup:update(dt)
	elseif gameType == 2 then
		Player:update(dt)
		Player2:update(dt)
		Ball:update(dt)
		Score:update(dt)
		Powerup:update(dt)
	end
end

function love.draw()
	if gameType == 0 then
		Menu.draw()
	elseif gameType == 1 then
		Player:draw()
		Ball:draw()
		AI:draw()
		Score:draw()
		Powerup:draw()
	elseif gameType == 2 then
		Player:draw()
		Player2:draw()
		Ball:draw()
		Score:draw()
		Powerup:draw()
	end
end

function checkCollision(a, b)
	if a.x + a.width > b.x and a.x < b.x + b.width and a.y + a.height > b.y and a.y < b.y + b.height then
		return true
	else
		return false
	end
end

function checkGametype()
	return gameType
end

function changeGametype(x)
	Score:reset()
	Ball:load()
	Player:load()
	Player2:load()
	Powerup:load()
	gameType = x
end