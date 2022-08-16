--putting a simple window together
require("gameloop")

GUIPrototype = {}

function handButton( text, fn )
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		active = true
	}
end

function shopButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		active = false
	}
end

function outcomeButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		active = true
	}
end

function bagButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		size = 0,
		active = false
	}
end

function keepRerollButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		active = true
	}
end

--need to be available from outside to set buttons to active
handButtons = {}
shopButtons = {}
outcomeButtons = {}
bagButtons = {}
enemyHandButtons = {}
enemyOutcomeButtons = {}
enemyBagButtons = {}
keepReroll = nil
enemyKeepReroll = keepRerollButton("Keep\nReroll")
enemyKeepReroll.active = false

local shopCosts = {1,2,4,8,16}
local font = nil
local defaultColor = {0.4, 0.4, 0.5, 1.0}
local hotButtonColor = {0.8, 0.8, 0.9, 1.0}
local textColour = {0, 0, 0, 1.0}
local boxX = 0
local instructions = "Welcome, Pick reroll for now :P"
local windowW
local windowH
local mouseX, mouseY 

function GUIPrototype:load()
	windowW = love.graphics.getWidth()
	windowH = love.graphics.getHeight()
	boxX = windowW/20
	font = love.graphics.newFont(windowW/82)

	gameloop:initialisation("Player", "gui", "Enemy", "random")
	--true aafter player input, set to false after decision made TODO!!!
	self.inputLock = false
	self.player = nil
	self.enemy = nil
	self.shop = nil

	self.debugTimer = 0

	--will be run after gameloop init
	self:fetchEnemy()
	self:fetchPlayer()
	self:fetchShop()
	

	self:refreshScreen()

	--TODO add info and menu buttons

	--set button functions
	--function will set player.choiceMade
	--then set inputlock to true
end

--makes buttons and sets functions
function GUIPrototype:refreshScreen()
	--set all button lists to 0
	shopButtons = {}

	handButtons = {}
	outcomeButtons = {}
	bagButtons = {}

	enemyHandButtons = {}
	enemyOutcomeButtons = {}
	enemyBagButtons = {}

	--populate shop
	for i = 1, 5, 1 do
		table.insert(shopButtons, shopButton(
			self.shop.run[i],
			function()
				print("clicked shop " .. i)
				self:makePlayerChoice(self.player, i)
				self.inputLock = true
			end
		))
	end

	--populate bags (deck, discard, grave)
	local labels = {"Deck", "Discard", "Grave"}
	for i = 1, 3, 1 do
		table.insert(bagButtons, bagButton(
			labels[i],
			function()
				--TODO bag functionality
				print("Clicked on a bag "..i)
			end
		))
		if i == 1 then
			bagButtons[i].size = #self.player.deck
		elseif i == 2 then
			bagButtons[i].size = #self.player.discard
		else
			bagButtons[i].size = #self.player.grave
		end
	end

	--populate prototype enemy bags (deck, discard, grave)
	local labels = {"Deck", "Discard", "Grave"}
	for i = 1, 3, 1 do
		table.insert(enemyBagButtons, bagButton(labels[i].."E"))
		if i == 1 then
			enemyBagButtons[i].size = #self.enemy.deck
		elseif i == 2 then
			enemyBagButtons[i].size = #self.enemy.discard
		else
			enemyBagButtons[i].size = #self.enemy.grave
		end
	end

	keepReroll = keepRerollButton(
		"Keep\nReroll",
		function()
			self:makePlayerChoice(self.player, 6)
			self.inputLock = true
		end
	)
	keepReroll.now = true

	--populate player hand
	for i = 1, 5, 1 do
		table.insert(handButtons, handButton(
			self.player.hand[i],
			function()
				self:makePlayerChoice(self.player, i)
				self.inputLock = true
			end
		))
		handButtons[i].now = true
	end
	--populate outcomes
	--used to make rerolls
	for i = 1, 5, 1 do
		table.insert(outcomeButtons, outcomeButton(
			"-",
			function()
				self:makePlayerChoice(self.player, i)
				self.inputLock = true
			end
		))
		outcomeButtons[i].active = false
		outcomeButtons[i].now = true

	end

	--populate enemy side
	--populate enemy hand
	for i = 1, 5, 1 do
		table.insert(enemyHandButtons, handButton(self.enemy.hand[i]))
		--TODO multiplayer, for now no enemy choices, all random
		enemyHandButtons[i].active = false
	end
	--populate enemy outcomes
	for i = 1, 5, 1 do
		table.insert(enemyOutcomeButtons, outcomeButton("-"))
		enemyOutcomeButtons[i].active = false
	end
end

function GUIPrototype:refreshShop()
	--empty shop
	shopButtons = {}
	--populate shop
	for i = 1, 5, 1 do
		table.insert(shopButtons, shopButton(
			self.shop.run[i],
			function()
				print("clicked shop " .. i)
				self:makePlayerChoice(self.player, i)
				self.inputLock = true
			end
		))
	end

	GUIPrototype:setButtonActive(shopButtons, true)
end

function GUIPrototype:setButtonActive(buttonList, activate)
	for i, button in ipairs(buttonList) do
		button.active = activate
	end
end

function GUIPrototype:makePlayerChoice(p,i)
	print("GUI Player made choice "..i)
	p.choiceMade = i
end


--handles game loop
function GUIPrototype:update(dt)
	--fetch the gamestate and print
	--lock irrelevant buttons
	--get input from player/s
	if dt == nil then
	else
		self.debugTimer = self.debugTimer + dt
	end

	--self.inputLock = true
	if gameloop.Gamestate == 1 then
		gameloop:startRound()
		self:refreshScreen()
		GUIPrototype:setButtonActive(handButtons, true)
		
		instructions = "Just click reroll for now pls :P"
		keepReroll.text = "Keep\nReroll"
		self.inputLock = false
	elseif gameloop.Gamestate == 2 and self.inputLock then
		gameloop:swapOrReroll()
		self:refreshScreen()
		--TODO handle swapin choice with popuplast
		--currently swapping in same # as swapped out

		self.inputLock = false
		GUIPrototype:setButtonActive(handButtons, false)
	elseif gameloop.Gamestate == 3 then
		gameloop:rollHand()
		GUIPrototype:fetchOutcomes()
		
		instructions = "Select who to reroll"
		keepReroll.text = "Throw\nReroll"
	elseif gameloop.Gamestate == 4 and self.inputLock then
		gameloop:rerolls()
		GUIPrototype:fetchOutcomes()

		self.inputLock = false
	elseif gameloop.Gamestate == 5 then
		gameloop:measureOutcomes()

		GUIPrototype:setButtonActive(outcomeButtons, false)
	elseif gameloop.Gamestate == 6 then
		--TODO handle empower choice with popup
		gameloop:prefight()

	elseif gameloop.Gamestate == 7 then
		gameloop:fight()

	elseif gameloop.Gamestate == 8 then
		--TODO steal revive popup
		--TODO handle revives with popups
		gameloop:prekills()

	elseif gameloop.Gamestate == 9 then
		--TODO handle target choice with popup
		gameloop:kills()

	elseif gameloop.Gamestate == 10 then
		--TODO handle skip with popup
		--problem with dead dice still on screen?
		--some way of replacing dead dice with filler?
		--honestly just a popup for now
		gameloop:postkills()
		GUIPrototype:setButtonActive(shopButtons, true)
		
		instructions = "Select purchase from shop?"
		keepReroll.text = "Keep\nMoney"

	elseif gameloop.Gamestate == 11 then
		--handle shopping one at a time
		if shop.firstPick == gameloop.p2 and shop.firstGone == false then
			--p2 is first, let them go
			gameloop:shopping()
			GUIPrototype:refreshShop()
		elseif shop.firstPick == gameloop.p1 and shop.firstGone == false and self.inputLock then
			--p1 is first, wait for input lock
			gameloop:shopping()
			GUIPrototype:refreshShop()
		elseif shop.firstGone then
			--second shopper
			if shop.firstPick == gameloop.p2 and self.inputLock then
				--p1 goes second, wait for input
				gameloop:shopping()
				GUIPrototype:refreshShop()
			elseif shop.firstPick == gameloop.p1 then
				--p2 goes second
				gameloop:shopping()
				GUIPrototype:refreshShop()
			end
		end

		self.inputLock = false
	elseif gameloop.Gamestate == 12 then
		gameloop:checkForWinner()

		GUIPrototype:setButtonActive(shopButtons, false)
	elseif gameloop.Gamestate == -1 then
		--gameover
		print("Gameover")
		love.event.quit()
	end
	
	if self.debugTimer > 1 then
		print("GameState waiting "..gameloop.Gamestate)
		self.debugTimer = 0
	end
end

function GUIPrototype:fetchPlayer()
	self.player = gameloop:getPlayer()
end

function GUIPrototype:fetchEnemy()
	self.enemy = gameloop:getPlayer2()
end	

function GUIPrototype:fetchShop()
	self.shop = gameloop:getShop()
end	

function GUIPrototype:fetchOutcomes()
	for i = 1, 5, 1 do
		outcomeButtons[i].text = self.player.outcomes[i]
		outcomeButtons[i].active = true
	end
	for i = 1, 5, 1 do
		enemyOutcomeButtons[i].text = self.enemy.outcomes[i]
	end
end

function GUIPrototype:printShopButtons()
	--shop buttons
	local shopY = boxX/2
	local shopBX = boxX * 4.5
	for xOffset, shopB in ipairs(shopButtons) do
		shopB.last = shopB.now
		--check if hovering mouse
		local hovering = mouseX > shopBX and mouseX < shopBX + boxX
			and mouseY > shopY and mouseY < shopY + boxX
		shopB.now = love.mouse.isDown(1)
		if hovering and shopB.active then
			love.graphics.setColor(unpack(hotButtonColor))
			if shopB.now and not shopB.last then
				shopB.fn()
			end
		else
			love.graphics.setColor(unpack(defaultColor))
		end
		--draw the box
		love.graphics.rectangle("fill",shopBX,shopY,boxX,boxX)
		--write in text on shop button
		love.graphics.setColor(textColour)
		love.graphics.print(shopB.text,font,shopBX,shopY)
		--write in price under shop button
		love.graphics.setColor(defaultColor)
		---@diagnostic disable-next-line: param-type-mismatch
		love.graphics.print(shopCosts[xOffset],font,shopBX,shopY+boxX)
		shopBX = shopBX + boxX
	end
	--Label shop
	love.graphics.setColor(defaultColor)
	love.graphics.print("Shop",font,shopBX,shopY)
end

function GUIPrototype:printBagButtons(bags, x, y, w)
	for yOffset, bagB in ipairs(bags) do
		bagB.last = bagB.now
		--manage hovering
		local hovering = mouseX > x and mouseX < x + w
			and mouseY > y and mouseY < y + w
		bagB.now = love.mouse.isDown(1)
		if hovering and bagB.active then
			love.graphics.setColor(unpack(hotButtonColor))
			if bagB.now and not bagB.last then
				bagB.fn()
			end
		else
			love.graphics.setColor(unpack(defaultColor))
		end
		--draw the box
		love.graphics.rectangle("fill",x,y,w,w)
		--write in text on bag button, incl bag size
		love.graphics.setColor(textColour)
		love.graphics.print(bagB.text .. "\n" .. bagB.size ,font,x,y)
		
		--+1.5x + 0.5x
		y = y + 2 * boxX
	end
end

function GUIPrototype:printHand(hand, offsetHandX)
	for yOffset, diceH in ipairs(hand) do
		--where diceH is the button holding the dice
		local handButtY = boxX * 2.5 + boxX*(yOffset-1)
		diceH.last = diceH.now

		--Dice type box
		love.graphics.setColor(unpack(defaultColor))
		love.graphics.rectangle(
			"fill",
			offsetHandX,
			handButtY,
			boxX,
			boxX
		)
		--write name of dice on box?
		if diceH.text == nil then
			diceH.text = "-"
		end

		love.graphics.setColor(textColour)
		love.graphics.print(
			diceH.text,
			font,
			offsetHandX,
			handButtY
		)

		--all sides on the dice in hand
		for xOffset = 1, 6, 1 do
			love.graphics.setColor(xOffset/10, xOffset/10, xOffset/10, 1)
			love.graphics.rectangle(
				"fill",
				offsetHandX + boxX + (boxX/2) * (xOffset-1),
				handButtY,
				boxX/2,
				boxX/2
			)
		end
		--swap button
		local swapButtonX = offsetHandX + boxX * 4
		local swapButtonWidth = boxX * 1.5
		local swapButtonHeight = boxX

		--check if hovering mouse
		local hovering = mouseX > swapButtonX and mouseX < swapButtonX + swapButtonWidth
			and mouseY > handButtY and mouseY < handButtY + swapButtonHeight
		diceH.now = love.mouse.isDown(1)
		if hovering and diceH.active then
			love.graphics.setColor(unpack(hotButtonColor))
			if diceH.now and not diceH.last then
				diceH.fn()
			end
		else
			love.graphics.setColor(unpack(defaultColor))
		end
		love.graphics.rectangle(
			"fill",
			swapButtonX,
			handButtY,
			swapButtonWidth,
			swapButtonHeight
		)

		--write in text on swap
		love.graphics.setColor(textColour)
		love.graphics.print(
			"Swap",
			font,
			swapButtonX + 4,
			handButtY + 2
		)
	end
end

function GUIPrototype:printOutcomes(outcomes, x, y)
	for xOffset, pOutcomeB in ipairs(outcomes) do
		--check if hovering mouse
		pOutcomeB.last = pOutcomeB.now
		local hovering = mouseX > x and mouseX < x + boxX
			and mouseY > y and mouseY < y + boxX
		pOutcomeB.now = love.mouse.isDown(1)
		if hovering and pOutcomeB.active then
			love.graphics.setColor(unpack(hotButtonColor))
			if pOutcomeB.now and not pOutcomeB.last then
				pOutcomeB.fn()
			end
		else
			love.graphics.setColor(unpack(defaultColor))
		end
		--draw the box
		love.graphics.rectangle("fill",x,y,boxX,boxX)
		--write in text on pOutcome button
		love.graphics.setColor(textColour)
		love.graphics.print(pOutcomeB.text,font,x,y)
		x = x + boxX
	end
end

function GUIPrototype:printKeepRerollButton(rButton,keepRerollButtonX,y)
	--keep reroll button
	local keepRerollButtonWidth = boxX * 1.5
	local keepRerollButtonHeight = boxX
	rButton.last = rButton.now

	--check if hovering mouse
	local hovering = mouseX > keepRerollButtonX and mouseX < keepRerollButtonX + keepRerollButtonWidth
		and mouseY > y and mouseY < y + keepRerollButtonHeight
	rButton.now = love.mouse.isDown(1)
	if hovering and rButton.active then
		love.graphics.setColor(unpack(hotButtonColor))
		if rButton.now and not rButton.last then
			rButton.fn()
		end
	else
		love.graphics.setColor(unpack(defaultColor))
	end
	love.graphics.rectangle(
		"fill",
		keepRerollButtonX,
		y,
		keepRerollButtonWidth,
		keepRerollButtonHeight
	)

	--write in text on keepReroll
	love.graphics.setColor(textColour)
	love.graphics.print(
		rButton.text,
		font,
		keepRerollButtonX + 4,
		y + 2
	)
end

function GUIPrototype:draw()
	windowW = love.graphics.getWidth()
	--windowH = love.graphics.getHeight()
	boxX = windowW/20

	mouseX, mouseY = love.mouse.getPosition()

	--shop buttons
	self:printShopButtons()

	--Player on the left hand of the screen
	--player bag buttons
	local bagX = boxX/2
	local bagBY = boxX * 1.5
	local bagWidth = boxX * 1.5
	self:printBagButtons(bagButtons, bagX, bagBY, bagWidth)

	--player 1 hand buttons
	local offsetHandX = boxX * 4
	self:printHand(handButtons, offsetHandX)

	--player outcome buttons
	local pOutcomeY = boxX * 8.5
	local pOutcomeBX = boxX * 4
	self:printOutcomes(outcomeButtons, pOutcomeBX, pOutcomeY)

	--player keep reroll button
	self:printKeepRerollButton(keepReroll, 8*boxX, 7.5*boxX)

	--Enemy on right side of the screen
	--enemy bag buttons
	bagX = windowW - boxX * 2
	bagBY = boxX * 1.5
	self:printBagButtons(enemyBagButtons, bagX, bagBY, bagWidth)

	--enemy hand buttons
	offsetHandX = boxX * 10.5
	self:printHand(enemyHandButtons, offsetHandX)

	--enemy outcome buttons
	local eOutcomeY = pOutcomeY
	local eOutcomeBX = boxX * 11
	self:printOutcomes(enemyOutcomeButtons, eOutcomeBX, eOutcomeY)

	--enemy keep reroll button
	self:printKeepRerollButton(enemyKeepReroll, 14.5*boxX, 7.5*boxX)

	--print instructions at bottom
	love.graphics.setColor(defaultColor)
	love.graphics.print(instructions,font, 5.5*boxX, 10.5 * boxX)
end