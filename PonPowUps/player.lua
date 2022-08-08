Player = {}

function Player:load()
	self.width = love.graphics.getWidth() / 64
	self.height = love.graphics.getHeight() / 7
	self.speed = love.graphics.getHeight()
	self.pyV = love.graphics.getHeight() / 72
	
	self.x = 50
	self.y = love.graphics.getHeight() / 2
end

function Player:update(dt)
	self:move(dt)
	self:checkBoundaries()
	
end

function Player:move(dt)
	if love.keyboard.isDown("w") then
		self.y = self.y - self.speed * dt
	elseif love.keyboard.isDown("s") then
		self.y = self.y + self.speed * dt
	end
end

function Player:checkBoundaries()
	if self.y < 0 then
		self.y = 0
	elseif self.y + self.height > love.graphics.getHeight() then
		self.y = love.graphics.getHeight() - self.height
	end
end

function Player:draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end


