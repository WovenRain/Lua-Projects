Score = {}

function Score:load()
	self.scoreA = 0
	self.scoreB = 0
	
	self.font = love.graphics.newFont("minecraft/minecraft.ttf", 32)
end

function Score:update(dt)

end

function Score:reset()
	self.scoreA = 0
	self.scoreB = 0
end

function Score:addA()
	self.scoreA = self.scoreA + 1
end

function Score:addB()
	self.scoreB = self.scoreB + 1
end

function Score:scoreString()
	return tostring(self.scoreA) .. " : " .. tostring(self.scoreB)
end

function Score:draw()
	--this is a stupid function that has no sensible arguement order. Beware
	love.graphics.setColor(1,1,1,1)
	love.graphics.printf(self:scoreString(), self.font, love.graphics.getWidth() /2 - 50, 50, 100, "center")
end