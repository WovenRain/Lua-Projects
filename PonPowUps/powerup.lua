Powerup = {}

powerups = {
	{"bigger paddle", { 0.9, 0, 0.9, 1 }},
	{"bigger ball", { 0, 0.9, 0.9, 1 }},
	{"faster paddle", { 0.9, 0.9, 0, 1 }},
	{"higher angle paddle", { 0.2, 0.9, 0, 1 }},
}

function Powerup:load()
	self.width = love.graphics.getWidth() / 32
	self.height = self.width
	self.x = love.graphics.getWidth() / 2 - self.width / 2
	self.y = love.graphics.getHeight() / 2 - self.width / 2

	self.timer = 0
	self.alive = false
	self.type = nil
	math.randomseed(os.time())
end

function Powerup:update(dt)
	-- no check for if alive
	-- meaning powerup changes after 5 seconds
	self.timer = self.timer + dt
	if self.timer > 5 then
		self.timer = 0
		self.alive = true
		self.type = math.random(1,4)
		--print(self.type)
	end
end

function Powerup:givePower(paddle)
	self.alive = false
	
	-- check powerup type
	-- give paddle effect
	
	if self.type == 1 then
		-- increase paddle height to a limit
		-- proportionally decrease pyV past maximum width
		-- making the powerup bad if you're already max size
		print(powerups[self.type][1])
		
		paddle.height = paddle.height * 1.3
		paddle.pyV = paddle.pyV / 1.3
		-- limit paddle size
		if paddle.height > love.graphics.getHeight() / 2 then
			paddle.height = love.graphics.getHeight() / 2
		end
	elseif self.type == 2 then
		-- make ball bigger... 
		-- TODO !!!!! on your side of the screen?
		print(powerups[self.type][1])
		
		Ball.width = Ball.width * 1.5
		Ball.height = Ball.height * 1.5
		-- limit ball size
		if Ball.width > love.graphics.getHeight() / 3 then
			Ball.width = love.graphics.getHeight() / 3
			Ball.height = love.graphics.getHeight() / 3
		end
	elseif self.type == 3 then
		-- increase paddle speed
		-- slightly decrease paddle size
		-- making the powerup bad if you're maxed out
		print(powerups[self.type][1])
		
		paddle.speed = paddle.speed * 1.5
		paddle.height = paddle.height * 0.9
		-- limit paddle speed
		if paddle.speed > love.graphics.getHeight() * 3 then
			paddle.speed = love.graphics.getHeight() * 3
		end
	elseif self.type == 4 then
		-- increase pyV in paddle
		print(powerups[self.type][1])
		
		paddle.pyV = paddle.pyV * 1.5
	end
end

function Powerup:draw()
	if self.alive then
		love.graphics.setColor(powerups[self.type][2])
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end
end