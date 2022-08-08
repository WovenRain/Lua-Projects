
AI = {}

function AI:load()
	self.width = love.graphics.getWidth() / 64
	self.height = love.graphics.getHeight() / 7
	self.speed = love.graphics.getHeight()
	self.pyV = love.graphics.getHeight() / 72
	
	self.x = love.graphics.getWidth() - self.width - 50
	self.y = love.graphics.getHeight() / 2
	
	self.yVel = 0
	self.timer = 0
	self.rate = 0.3
end

function AI:update(dt)
	self:move(dt)
	self.timer = self.timer + dt
	if self.timer > self.rate then
		self.timer = 0
		self:acquireTarget()
	end
end

function AI:move(dt)
	self.y = self.y + self.yVel * dt
end

function AI:acquireTarget()
	if Ball.y + Ball.height < self.y then
		self.yVel = -self.speed
	elseif self.y + self.height < Ball.y then
		self.yVel = self.speed
	else
		self.yVel = 0
	end
end

function AI:draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end