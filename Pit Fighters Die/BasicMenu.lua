BasicMenu = {}

local font = nil
local defaultColor = {0.4, 0.4, 0.5, 1.0}
local hotColor = {0.8, 0.8, 0.9, 1.0}

BUTTON_HEIGHT = 64

function BasicMenu.load()
	font = love.graphics.newFont(32)
end

function BasicMenu.draw(buttons)
	local ww = love.graphics.getWidth()
	local wh = love.graphics.getHeight()
	
	local button_width = ww * (1/3)
	local yMargin = 16
	
	local total_height = (BUTTON_HEIGHT + yMargin) * #buttons
	
	local yOffset = 0
	
	local mx,my = love.mouse.getPosition()
	
	for i, button in ipairs(buttons) do
		button.last = button.now
	
		local bx = (ww * 2/3) - (button_width / 2)
		local by = (wh / 2) - (total_height / 2) + yOffset
		
		--draw the rectangle
		
		local color = defaultColor
		local hot = mx > bx and mx < bx + button_width 
				and my > by and my < by + BUTTON_HEIGHT
		
		button.now = love.mouse.isDown(1)
		if hot then
			color = hotColor
			if button.now and not button.last then
				button.fn()
			end
		end
		
		love.graphics.setColor(unpack(color))
		love.graphics.rectangle(
			"fill",
			bx,
			by,
			button_width,
			BUTTON_HEIGHT
		)
		
		--write the text in
		love.graphics.setColor( 0, 0, 0, 1.0)
		
		local textW = font:getWidth(button.text)
		local textH = font:getHeight(button.text)
		
		love.graphics.print(
			button.text, 
			font, 
			(ww * 2/3) - (textW / 2), 
			by + (textH / 2) - 6
		)
			
		
		yOffset = yOffset + (BUTTON_HEIGHT + yMargin)
	end
end