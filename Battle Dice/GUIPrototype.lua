--putting a simple window together
require("gameloop")
require("graphics")

GUIPrototype = {}

function handButton(text, fn)
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

function popupButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false
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

popupButtons = {}

keepReroll = nil
enemyKeepReroll = keepRerollButton("Keep\nReroll")
enemyKeepReroll.active = false

local shopCosts = {1,2,4,8,16}
local font = nil
local defaultColor = {0.4, 0.4, 0.5, 1.0}
local hotButtonColor = {0.8, 0.8, 0.9, 1.0}
local textColour = {0, 0, 0, 1.0}
local boxX = 0
local instructions = "Welcome, Pick to swap out dice or keep a reroll"
local windowW
local windowH
local mouseX, mouseY 

function GUIPrototype:load()
	windowW = love.graphics.getWidth()
	windowH = love.graphics.getHeight()
	boxX = windowW/20
	font = love.graphics.newFont(windowW/82)

	gameloop:initialisation("Player", "gui", "Number_1_Bot", "1")
	graphics:load()
	--true aafter player input, set to false after decision made
	self.inputLock = false
	self.player = nil
	self.enemy = nil
	self.shop = nil

	self.debugTimer = 0

	--will be run after gameloop init
	self:fetchEnemy()
	self:fetchPlayer()
	self:fetchShop()
	
	--to control various popups
	self.swapInPopupOn = false
	self.empowerPopupOn = false
	self.revivePopupOn = false
	self.stealRevivePopupOn = false
	self.targetPopupOn = false
	self.skipPopupOn = false

	self:refreshScreen()

	--TODO add info and menu buttons
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

function GUIPrototype:refreshBags()
	bagButtons = {}
	enemyBagButtons = {}
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

function GUIPrototype:empowerPopup()
	self.empowerPopupOn = true
	popupButtons = {}
	
	table.insert(popupButtons, popupButton(
		"Empower Attack ",
		function()
			self.player.choiceMade = 1
			self.empowerPopupOn = false
			self.inputLock = true
		end
	))
	table.insert(popupButtons, popupButton(
		"Empower Defence ",
		function()
			self.player.choiceMade = 2
			self.empowerPopupOn = false
			self.inputLock = true
		end
	))
	popupButtons[1].now = true
	popupButtons[2].now = true
end

function GUIPrototype:swapInPopup()
	self.swapInPopupOn = true
	popupButtons = {}
	for i = 1, #self.player.deck, 1 do
		table.insert(popupButtons, popupButton(
			"Swap for "..self.player.deck[i],
			function()
				self.player.choiceMade = i
				self.swapInPopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
end

function GUIPrototype:revivePopup()
	self.revivePopupOn = true
	popupButtons = {}
	for i = 1, #self.player.grave, 1 do
		table.insert(popupButtons, popupButton(
			"Revive "..self.player.grave[i],
			function()
				self.player.choiceMade = i
				self.revivePopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
end

function GUIPrototype:stealRevivePopup()
	self.stealRevivePopupOn = true
	popupButtons = {}
	for i = 1, #self.enemy.grave, 1 do
		table.insert(popupButtons, popupButton(
			"Steal Revive "..self.enemy.grave[i],
			function()
				self.player.choiceMade = i
				self.stealRevivePopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
end

function GUIPrototype:targetPopup()
	self.targetPopupOn = true
	popupButtons = {}
	for i = 1, #self.enemy.hand, 1 do
		table.insert(popupButtons, popupButton(
			"Target Kill "..self.enemy.hand[i],
			function()
				self.player.choiceMade = i
				self.targetPopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
end

function GUIPrototype:skipPopup()
	self.skipPopupOn = true
	popupButtons = {}
	for i = 1, #self.player.hand, 1 do
		table.insert(popupButtons, popupButton(
			"Skip "..self.player.hand[i].." past Discard",
			function()
				self.player.choiceMade = i
				self.skipPopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
end

--handles game loop
--fucking horrendous and bloated and messy
--where like all of the bugs are
--things are preemptive and desynced
--TODO big clean up
function GUIPrototype:update(dt)
	--fetch the gamestate and print
	--lock irrelevant buttons
	--get input from player/s
	if dt == nil then
	else
		self.debugTimer = self.debugTimer + dt
	end

	--skip inputlock is player is random
	--flashes over everything in an instant
	--TODO animations would require stops/waits for animation completions
	if gameloop.p1.type == "random" then
		--playing with fire here
		self.inputLock = true
	end

	if gameloop.Gamestate == 1 then
		gameloop:startRound()
		self:refreshScreen()
		GUIPrototype:setButtonActive(handButtons, true)
		
		instructions = "Swap out a Dice or keep a Reroll"
		keepReroll.text = "Keep\nReroll"
		self.inputLock = false
	elseif gameloop.Gamestate == 2 and self.inputLock then
		gameloop:swapOrReroll()
		self:refreshScreen()

		self.inputLock = false
		GUIPrototype:setButtonActive(handButtons, false)
		keepReroll.active = false
	elseif gameloop.Gamestate == 25 and self.inputLock then
		gameloop:swapIn()

		self.inputLock = false
		self:refreshScreen()
		GUIPrototype:setButtonActive(handButtons, false)
	elseif gameloop.Gamestate == 3 then
		gameloop:rollHand()
		GUIPrototype:fetchOutcomes()
		
		instructions = "Select who to reroll"
		keepReroll.text = "Throw\nReroll"
		keepReroll.active = true
	elseif gameloop.Gamestate == 4 then--and self.inputLock then
		--if player has a reroll, wait for player input
		if self.player.rerolls > 0 and self.inputLock then
			gameloop:rerolls()
			GUIPrototype:fetchOutcomes()
		end
		if self.player.rerolls == 0 then
			gameloop:rerolls()
			GUIPrototype:fetchOutcomes()
		end

		self.inputLock = false
	elseif gameloop.Gamestate == 5 then
		gameloop:measureOutcomes()
		GUIPrototype:setButtonActive(outcomeButtons, false)
		if self.player.empowers > 0 then
			--print empowerPopup
			self:empowerPopup()
		else
			self.inputLock = true
		end

		keepReroll.active = false
	elseif gameloop.Gamestate == 6 and self.inputLock then
		gameloop:prefight()
		if self.player.empowers > 0 then
			--print empowerPopup
			self:empowerPopup()
			self.inputLock = false
		end
	elseif gameloop.Gamestate == 7 then
		gameloop:fight()
		self.empowerPopupOn = false
		
		self.inputLock = true
		--set up for next phase
		if self.player.revives > 0 and #self.player.grave > 0 and self.enemy.steals == 0 then
			--player has revives
			self:revivePopup()
			self.inputLock = false
		elseif self.enemy.revives > 0 and self.player.steals > 0 and #self.enemy.grave > 0 then
			--enemy has revives and player has steals
			self:stealRevivePopup()
			self.inputLock = false
		end

		--TODO sort out bug where we get stuck on gamestate 8 with no need to input
		keepReroll.active = true
	elseif gameloop.Gamestate == 8 and self.inputLock then
		--TODO sort out bug when you have both steal revive and revive
		--it takes input from 
		if self.player.revives > 0 and #self.player.grave > 0 and self.enemy.steals == 0 then
			--player has revives
			self:revivePopup()
		elseif self.enemy.revives > 0 and self.player.steals > 0 and #self.enemy.grave > 0 then
			--enemy has revives and player has steals
			self:stealRevivePopup()
		end
		gameloop:prekills()
		self.inputLock = false
		--get ready for next round if player has targets
		if gameloop.p1.revives == 0 and gameloop.p2.revives == 0 and gameloop.p1.targets > 0 and gameloop.p1.kills > 0 then
			self:targetPopup()
		end
	elseif gameloop.Gamestate == 9 then
		self.revivePopupOn = false
		self.stealRevivePopupOn = false
		--handle one at a time again 
		--will help with animations as well
		if gameloop.p1.targets == 0 or gameloop.p1.kills == 0 then
			gameloop:kills()
			self.targetPopupOn = false
		elseif gameloop.p1.targets > 0 and gameloop.p1.kills > 0 and self.inputLock then
			gameloop:kills()
			self:targetPopup()
		end

		self:refreshBags()
		self.inputLock = false
		if gameloop.p1.skips > 0 and #gameloop.p1.hand > 0  and gameloop.p1.kills < 0 and gameloop.p2.kills < 0 then
			self:skipPopup()
		end
	elseif gameloop.Gamestate == 10 then
		self.targetPopupOn = false
		--TODO handle skip with popup
		if gameloop.p1.skips > 0 and #gameloop.p1.hand > 0 and self.inputLock then
			gameloop:playerSkip()
			self:skipPopup()
			self.inputLock = false
		end
		if gameloop.p1.skips == 0 then
			--deal with the rest
			gameloop:postkills()
		end
		self.inputLock = false

	elseif gameloop.Gamestate == 11 then
		self.skipPopupOn = false
		self:refreshBags()
		GUIPrototype:setButtonActive(shopButtons, true)
		instructions = "Select purchase from shop?"
		keepReroll.text = "Keep\nMoney"
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
		self:refreshBags()
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
		if shopB.text == nil then
			love.graphics.print("-",font,shopBX,shopY)
		else
			graphics:printDicePlate(shopB.text, shopBX, shopY, 1)
			love.graphics.print(shopB.text,font,shopBX,shopY)
		end
		--write in price under shop button
		love.graphics.setColor(defaultColor)
		---@diagnostic disable-next-line: param-type-mismatch
		love.graphics.print(shopCosts[xOffset],font,shopBX,shopY+boxX)
		shopBX = shopBX + boxX
	end
	--Label shop
	love.graphics.setColor(defaultColor)
	love.graphics.print(string.format("Shop\n%i", #gameloop.shop.deck),font,shopBX,shopY)
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
		--dice plate
		graphics:printDicePlate(diceH.text, offsetHandX, handButtY, 1)
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
			--love.graphics.setColor(xOffset/10, xOffset/10, xOffset/10, 1)
			love.graphics.setColor(defaultColor)
			love.graphics.rectangle(
				"fill",
				offsetHandX + boxX + (boxX/2) * (xOffset-1),
				handButtY,
				boxX/2,
				boxX/2
			)
			graphics:printOutcome(
				dice[diceH.text][xOffset],
				offsetHandX + boxX + (boxX/2) * (xOffset-1), 
				handButtY,
				0.5
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
		graphics:printOutcome(pOutcomeB.text, x, y, 1)
		--write in text on pOutcome button
		love.graphics.setColor(textColour)
		--love.graphics.print(pOutcomeB.text,font,x,y)
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

function GUIPrototype:printPopupMenu()
	local button_width = windowW * (1/3)
	local popup_button_height = boxX
	local yMargin = boxX/3
	
	local total_height = (popup_button_height + yMargin) * #popupButtons
	
	local cursor_y = 0
	
	local mx,my = love.mouse.getPosition()
	
	for i, button in ipairs(popupButtons) do
		button.last = button.now
	
		local bx = (windowW / 2) - (button_width / 2)
		local by = (windowH / 2) - (total_height / 2) + cursor_y

		--black behind the buttons
		love.graphics.setColor(0.1,0.1,0.1,1)
		love.graphics.rectangle(
			"fill",
			bx - yMargin,
			by - yMargin,
			button_width + 2 * yMargin,
			popup_button_height + 2 * yMargin
		)
		--draw the rectangle
		local color = {0.4, 0.4, 0.5, 1.0}
		local hot = mx > bx and mx < bx + button_width 
				and my > by and my < by + popup_button_height
		
		button.now = love.mouse.isDown(1)
		if hot then
			color = {0.8, 0.8, 0.9, 1.0}
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
			popup_button_height
		)
		
		--write the text in
		love.graphics.setColor( 0, 0, 0, 1.0)
		
		local textW = font:getWidth(button.text)
		local textH = font:getHeight(button.text)
		
		love.graphics.print(
			button.text, 
			font, 
			(windowW / 2) - (textW / 2), 
			by + (textH / 2) - 6
		)
		cursor_y = cursor_y + (popup_button_height + yMargin)
	end
end

function GUIPrototype:draw()
	windowW = love.graphics.getWidth()
	windowH = love.graphics.getHeight()
	boxX = windowW/20

	mouseX, mouseY = love.mouse.getPosition()

	--player and enemy wallets
	--Label player wallet
	love.graphics.setColor(defaultColor)
	love.graphics.print(string.format("Wallet %i", gameloop.p1.wallet),font,boxX,boxX/2)
	--Label enemy wallet
	love.graphics.print(string.format("Wallet %i", gameloop.p2.wallet),font,windowW - 2*boxX,boxX/2)

	--player and enemy lifetags
	--Label player and life
	love.graphics.setColor(defaultColor)
	love.graphics.print(string.format("%s life: %i", gameloop.p1.name, gameloop.p1:getLife()),font,boxX,windowH - boxX/2)
	--Label enemy and life
	love.graphics.print(string.format("%s life: %i", gameloop.p2.name, gameloop.p2:getLife()),font,windowW - 3*boxX,windowH - boxX/2)

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
	
	--popup for swap in
	if self.swapInPopupOn == true then
		--show it
		self:printPopupMenu()
	end

	--popup for empower
	if self.empowerPopupOn == true then
		--show it
		self:printPopupMenu()
	end

	--popup for revive
	if self.revivePopupOn == true then
		--show it
		self:printPopupMenu()
	end

	--popup for steal revive
	if self.stealRevivePopupOn == true then
		--show it
		self:printPopupMenu()
	end

	--popup for target
	if self.targetPopupOn == true then
		--show it
		self:printPopupMenu()
	end

	--popup for skip
	if self.skipPopupOn == true then
		--show it
		self:printPopupMenu()
	end

	--print instructions at bottom
	love.graphics.setColor(defaultColor)
	love.graphics.print(instructions,font, 5.5*boxX, 10.5 * boxX)
end