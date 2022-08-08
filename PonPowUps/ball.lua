Ball = {}

function Ball:load()
	self.x = love.graphics.getWidth() / 2
	self.y = love.graphics.getHeight() / 2
	self.width = love.graphics.getWidth() / 64
	self.height = love.graphics.getWidth() / 64
	self.speed = love.graphics.getWidth() * 25 / 64
	self.speedLimit = love.graphics.getWidth() * 7 / 8
	self.xVel = -self.speed
	self.yVel = 0
end

function Ball:update(dt)
	Ball:move(dt)
	Ball:collide()
	if self.speed > self.speedLimit then
		self.speed = self.speedLimit
	end
end

function Ball:move(dt)
	self.x = self.x + self.xVel * dt
	self.y = self.y + self.yVel * dt
end

function Ball:collide()
	-- collision with paddles
	if checkCollision(self, Player) then
		self.speed = self.speed + 50
		self.xVel = self.speed
		Ball:reflect(Player)
	elseif checkGametype() == 1 and checkCollision(self, AI) then
		self.speed = self.speed + 50
		self.xVel = -self.speed
		Ball:reflect(AI)
	elseif checkGametype() == 2 and checkCollision(self, Player2) then
		self.speed = self.speed + 50
		self.xVel = -self.speed
		Ball:reflect(Player2)
	end
	
	-- collision with roof and floor
	if self.y < 0 then
		self.y = 0
		self.yVel = -self.yVel
	elseif self.y + self.height > love.graphics.getHeight() then
		self.y = love.graphics.getHeight() - self.height
		self.yVel = -self.yVel
	end
	
	-- collision with powerups
	if checkCollision(self, Powerup) and Powerup.alive then
		-- if ball moving right, player hit last or lost round 
		if self.xVel > 0 then
			-- give powerup to player1
			Powerup:givePower(Player)
		else
			-- give powerup to opponent
			if checkGametype() == 1 then
				Powerup:givePower(AI)
			else
				Powerup:givePower(Player2)
			end
		end
	end
	
	-- collision with goals
	if self.x < 0 then
		self.x = love.graphics.getWidth() / 2 - self.width / 2 
		self.y = love.graphics.getHeight() / 2 - self.height / 2
		self.yVel = 0
		self.xVel = self.speed
		Score:addB()
	elseif self.x + self.width > love.graphics.getWidth() then
		self.x = love.graphics.getWidth() / 2 - self.width / 2 
		self.y = love.graphics.getHeight() / 2 - self.height / 2
		self.yVel = 0
		self.xVel = -self.speed
		Score:addA()
	end
end

function Ball:draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Ball:reflect(paddle)
	local middleBall = self.y + self.height / 2
	local middlePaddle = paddle.y + paddle.height / 2
	local collisionPosition = middleBall - middlePaddle
	self.yVel = collisionPosition * paddle.pyV
end

