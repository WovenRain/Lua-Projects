require("gameloop")
require("graphics")
require("Buttons")
require("outcomes")

gameGUI = {}

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
local font,title = nil,nil
local defaultColor = {0.5, 0.5, 0.6, 1.0}
local hotButtonColor = {0.8, 0.8, 0.9, 1.0}
local inactiveButtonColor = {0.4, 0.4, 0.5, 1.0}
local textColour = {0, 0, 0, 1.0}
local boxX = 0
local instructions = "Welcome, Pick to swap out dice or keep a reroll"
local windowW
local windowH
local mouseX, mouseY 

Animating = false
Animation = ""
AnimationTimer = 0
AnimationLength = 0

function gameGUI:load(p1name,p1type,p1plate,p2name,p2type,p2plate)
	windowW = love.graphics.getWidth()
	windowH = love.graphics.getHeight()
	boxX = windowW/20
	font = love.graphics.newFont(windowW/78)
	title = love.graphics.newFont(windowW/42)

	self.frameTimer = 0
	self.frameLimiter = 1/60

	instructions = "Welcome, Pick to swap out dice or keep a reroll"
	enemyKeepReroll = keepRerollButton("Keep\nReroll")

	gameloop:initialisation(p1name, p1type, p1plate, p2name, p2type, p2plate)
	--graphics:load()
	--true aafter player input, set to false after decision made
	self.inputLock = false

	self.debugTimer = 0

	Animating = false

	--TODO add info and menu buttons
	self.infoScreenOn = false
	self.infoButton = newButton(
		"i",
		function()
			self.infoScreenOn = not self.infoScreenOn
		end
	)
	
	--to control various popups
	self.swapInPopupOn = false
	self.empowerPopupOn = false
	self.revivePopupOn = false
	self.stealRevivePopupOn = false
	self.targetPopupOn = false
	self.skipPopupOn = false
	self.gameoverScreenOn = false

	self.bagContents = nil

	self:refreshScreen()
end

--makes buttons and sets functions
function gameGUI:refreshScreen()
	--set all button lists to 0
	--shopButtons = {}

	handButtons = {}
	outcomeButtons = {}
	--bagButtons = {}

	enemyHandButtons = {}
	enemyOutcomeButtons = {}
	--enemyBagButtons = {}

	self:refreshShop()
	self:refreshBags()

	keepReroll = keepRerollButton(
		"Keep\nReroll",
		function()
			self:makePlayerChoice(gameloop.p1, 6)
			self.inputLock = true
		end
	)
	keepReroll.now = true

	--populate player hand
	for i = 1, 5, 1 do
		table.insert(handButtons, handButton(
			gameloop.p1.hand[i],
			function()
				self:makePlayerChoice(gameloop.p1, i)
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
				self:makePlayerChoice(gameloop.p1, i)
				self.inputLock = true
			end
		))
		outcomeButtons[i].active = false
		outcomeButtons[i].now = true
	end

	--populate enemy side
	--populate enemy hand
	for i = 1, 5, 1 do
		table.insert(enemyHandButtons, handButton(gameloop.p2.hand[i]))
		--TODO multiplayer, for now no enemy choices, all random
		enemyHandButtons[i].active = false
	end
	--populate enemy outcomes
	for i = 1, 5, 1 do
		table.insert(enemyOutcomeButtons, outcomeButton("-"))
		enemyOutcomeButtons[i].active = false
	end
	enemyKeepReroll.active = false

end

function gameGUI:refreshShop()
	--empty shop
	shopButtons = {}
	--populate shop
	for i = 1, 5, 1 do
		table.insert(shopButtons, shopButton(
			gameloop.shop.run[i],
			function()
				print("clicked shop " .. i)
				self:makePlayerChoice(gameloop.p1, i)
				self.inputLock = true
			end
		))
		shopButtons[i].now = true
	end

	--gameGUI:setButtonActive(shopButtons, true)
end

function gameGUI:refreshBags()
	bagButtons = {}
	enemyBagButtons = {}
	--populate bags (deck, discard, grave)
	local labels = {"Deck", "Discard", "Grave"}
	for i = 1, 3, 1 do
		if i == 1 then
			table.insert(bagButtons, bagButton(
				labels[i],
				function()
					print("Clicked on a bag "..i)
					if self.bagContents == "p1Deck" then
						self.bagContents = nil
					else
						self.bagContents = "p1Deck"
					end
				end
			))
			bagButtons[i].size = #gameloop.p1.deck
		elseif i == 2 then
			table.insert(bagButtons, bagButton(
				labels[i],
				function()
					print("Clicked on a bag "..i)
					if self.bagContents == "p1Discard" then
						self.bagContents = nil
					else
						self.bagContents = "p1Discard"
					end
				end
			))
			bagButtons[i].size = #gameloop.p1.discard
		else
			table.insert(bagButtons, bagButton(
				labels[i],
				function()
					print("Clicked on a bag "..i)
					if self.bagContents == "p1Grave" then
						self.bagContents = nil
					else
						self.bagContents = "p1Grave"
					end
				end
			))
			bagButtons[i].size = #gameloop.p1.grave
		end
		bagButtons[i].now = true
	end

	--populate prototype enemy bags (deck, discard, grave)
	for i = 1, 3, 1 do
		if i == 1 then
			table.insert(enemyBagButtons, bagButton(
				labels[i],
				function()
					print("Clicked on a bag "..i)
					if self.bagContents == "p2Deck" then
						self.bagContents = nil
					else
						self.bagContents = "p2Deck"
					end
				end
			))
			enemyBagButtons[i].size = #gameloop.p2.deck
		elseif i == 2 then
			table.insert(enemyBagButtons, bagButton(
				labels[i],
				function()
					print("Clicked on a bag "..i)
					if self.bagContents == "p2Discard" then
						self.bagContents = nil
					else
						self.bagContents = "p2Discard"
					end
				end
			))
			enemyBagButtons[i].size = #gameloop.p2.discard
		else
			table.insert(enemyBagButtons, bagButton(
				labels[i],
				function()
					print("Clicked on a bag "..i)
					if self.bagContents == "p2Grave" then
						self.bagContents = nil
					else
						self.bagContents = "p2Grave"
					end
				end
			))
			enemyBagButtons[i].size = #gameloop.p2.grave
		end
		enemyBagButtons[i].now = true
	end
end

function gameGUI:setButtonActive(buttonList, activate)
	for i, button in ipairs(buttonList) do
		button.active = activate
	end
end

function gameGUI:makePlayerChoice(p,i)
	print("gameGUI Player made choice "..i)
	p.choiceMade = i
end

function gameGUI:empowerPopup()
	self.empowerPopupOn = true
	popupButtons = {}
	
	table.insert(popupButtons, popupButton(
		"Empower Attack ",
		function()
			gameloop.p1.choiceMade = 1
			self.empowerPopupOn = false
			self.inputLock = true
		end
	))
	table.insert(popupButtons, popupButton(
		"Empower Defence ",
		function()
			gameloop.p1.choiceMade = 2
			self.empowerPopupOn = false
			self.inputLock = true
		end
	))
	popupButtons[1].now = true
	popupButtons[2].now = true
	self.inputLock = false
end

function gameGUI:swapInPopup(player)
	self.swapInPopupOn = true
	popupButtons = {}
	for i = 1, #player.deck, 1 do
		table.insert(popupButtons, popupButton(
			player.deck[i],
			function()
				player.choiceMade = i
				self.swapInPopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
	self.inputLock = false
end

function gameGUI:revivePopup(player)
	self.revivePopupOn = true
	popupButtons = {}
	for i = 1, #player.grave, 1 do
		table.insert(popupButtons, popupButton(
			player.grave[i],
			function()
				player.choiceMade = i
				self.revivePopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
	self.inputLock = false
end

function gameGUI:stealRevivePopup(player,opponent)
	self.stealRevivePopupOn = true
	popupButtons = {}
	for i = 1, #opponent.grave, 1 do
		table.insert(popupButtons, popupButton(
			opponent.grave[i],
			function()
				player.choiceMade = i
				self.stealRevivePopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
	self.inputLock = false
end

function gameGUI:targetPopup()
	self.targetPopupOn = true
	popupButtons = {}
	for i = 1, #gameloop.p2.hand, 1 do
		table.insert(popupButtons, popupButton(
			"Target Kill "..gameloop.p2.hand[i],
			function()
				gameloop.p1.choiceMade = i
				self.targetPopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
	self.inputLock = false
end

function gameGUI:skipPopup()
	self.skipPopupOn = true
	popupButtons = {}
	for i = 1, #gameloop.p1.hand, 1 do
		table.insert(popupButtons, popupButton(
			"Skip "..gameloop.p1.hand[i],
			function()
				gameloop.p1.choiceMade = i
				self.skipPopupOn = false
				self.inputLock = true
			end
		))
		popupButtons[i].now = true
	end
	self.inputLock = false
end

function gameGUI:printSimpleKills()
	gameloop.p1:calculate()
	gameloop.p2:calculate()
	gameloop.p1:measureKills(gameloop.p2)
	gameloop.p2:measureKills(gameloop.p1)
	instructions = instructions .. "\n" .. 
		gameloop.p1.name .. " Has " .. gameloop.p1.kills .. " Kills and " .. gameloop.p1.rerolls .. " Rerolls\n" ..
		gameloop.p2.name .. " Has " .. gameloop.p2.kills .. " Kills and " .. gameloop.p2.rerolls .. " Rerolls"
end

function gameGUI:setAnimation(a,l)
	Animating = true
	AnimationTimer = 0
	Animation = a
	AnimationLength = l
end

--handles game loop
--fucking horrendous and bloated and messy
--where like all of the bugs are
--things are preemptive and desynced
--TODO big clean up
function gameGUI:update(dt)
	--fetch the gamestate and print
	--lock irrelevant buttons
	--get input from player/s
	if dt == nil then
	else
		self.debugTimer = self.debugTimer + dt
		self.frameTimer = self.frameTimer + dt
		if self.frameTimer < self.frameLimiter then
			love.timer.sleep(self.frameLimiter - self.frameTimer)
		end
		self.frameTimer = 0

		if Animating then
			AnimationTimer = AnimationTimer + dt
			if AnimationTimer > AnimationLength then
				Animating = false
			end
		end
	end

	if self.debugTimer > 1 then
		print("GameState waiting "..gameloop.Gamestate)
		self.debugTimer = 0
	end

	--exit out after gameoverscreen
	if gameloop.Gamestate == -1 and Animating == false then
		--game is over and no longer animating
		print("Exiting GUI")
		changeGametype(0)
	elseif Animating then
		if Animation == "Gameover" then
			self.gameoverScreenOn = true
		end
		--dont do any more of the update loop
		return
	end

	--skip inputlock if player is random
	--flashes over everything in an instant
	--TODO animations would require stops/waits for animation completions
	if gameloop.p1.type == "random" then
		--playing with fire here
		self.inputLock = true
	end

	if self.infoScreenOn then
		--dont allow for any more input
		--doesnt really work
		return
	end

	--fucked bugfix, I mean it fucking works
	if gameloop.Gamestate == 8 and gameloop.p1.revives == 0 
		and gameloop.p1.steals == 0 and gameloop.p2.revives > 0 
		or
		(gameloop.Gamestate == 8 and
			#gameloop.p1.grave == 0 and #gameloop.p2.grave == 0) then
		self.inputLock = true
	end

	if gameloop.Gamestate == 1 then
		gameloop:startRound()
		self:refreshScreen()
		gameGUI:setButtonActive(handButtons, true)
		
		instructions = "Swap out a Dice or keep a Reroll"
		keepReroll.text = "Keep\nReroll"
		self.inputLock = false

	elseif gameloop.Gamestate == 2 and self.inputLock then
		gameloop:swapOrReroll()
		self:refreshScreen()

		gameGUI:setButtonActive(handButtons, false)
		keepReroll.active = false
		self.inputLock = false

	elseif gameloop.Gamestate == 25 and self.inputLock then
		gameloop:swapIn()

		self:refreshScreen()
		gameGUI:setButtonActive(handButtons, false)
		self.inputLock = false

	elseif gameloop.Gamestate == 3 then
		gameloop:rollHand()
		gameGUI:fetchOutcomes()
		
		instructions = "Select who to reroll"
		--this is liable to break things !!!!!!!!!!! Maybe do something better than this
		--either way think about it
		gameGUI:printSimpleKills()

		keepReroll.text = "Throw\nReroll"
		keepReroll.active = true
		self.inputLock = false

	elseif gameloop.Gamestate == 4 then
		gameGUI:setButtonActive(handButtons, true)
		--if player has a reroll, wait for player input
		if gameloop.p1.rerolls > 0 and self.inputLock then
			gameloop:rerolls()
			gameGUI:fetchOutcomes()
		end
		if gameloop.p1.rerolls == 0 then
			gameloop:rerolls()
			gameGUI:fetchOutcomes()
		end
		instructions = "Select who to reroll"
		gameGUI:printSimpleKills()

		self.inputLock = false

	elseif gameloop.Gamestate == 5 then
		gameloop:measureOutcomes()
		gameGUI:setButtonActive(outcomeButtons, false)
		gameGUI:setButtonActive(handButtons, false)
		if gameloop.p1.empowers > 0 then
			--print empowerPopup
			self:empowerPopup()
		else
			self.inputLock = true
		end
		keepReroll.active = false

	elseif gameloop.Gamestate == 6 and self.inputLock then
		gameloop:prefight()
		if gameloop.p1.empowers > 0 then
			--print empowerPopup
			self:empowerPopup()
		end

	elseif gameloop.Gamestate == 7 then
		gameloop:fight()
		self.empowerPopupOn = false
		
		--set up for next phase
		self.inputLock = true
		if gameloop.p1.revives > 0 and #gameloop.p1.grave > 0 and gameloop.p2.steals == 0 then
			--player has revives
			self:revivePopup(gameloop.p1)
		elseif gameloop.p2.revives > 0 and gameloop.p1.steals > 0 and #gameloop.p2.grave > 0 then
			--enemy has revives and player has steals
			self:stealRevivePopup(gameloop.p1, gameloop.p2)
		end
		keepReroll.active = true
		instructions = "Choose who to revive"
		keepReroll.text = "Let enemy\nRevive"

	elseif gameloop.Gamestate == 8 and self.inputLock then
		gameloop:prekills()
		--it takes input from 
		if gameloop.p1.revives > 0 and #gameloop.p1.grave > 0 and gameloop.p2.steals == 0 then
			--player has revives
			self:revivePopup(gameloop.p1)
		elseif gameloop.p2.revives > 0 and gameloop.p1.steals > 0 and #gameloop.p2.grave > 0 then
			--enemy has revives and player has steals
			self:stealRevivePopup(gameloop.p1, gameloop.p2)
		end
		--get ready for next round if player has targets
		if gameloop.p1.revives == 0 and gameloop.p2.revives == 0 
			and gameloop.p1.targets > 0 and gameloop.p1.kills > 0 
			and gameloop.p2.occlude == 0 then
			self:targetPopup()
		end
		self.inputLock = false
		instructions = "Select from shop."

	elseif gameloop.Gamestate == 9 then
		self.revivePopupOn = false
		self.stealRevivePopupOn = false

		--handle one at a time again 
		--will help with animations as well
		if gameloop.p1.targets == 0 or gameloop.p1.kills == 0 then
			instructions = instructions .. "\n" .. gameloop:kills()
			self.targetPopupOn = false
		elseif gameloop.p1.targets > 0 and gameloop.p1.kills > 0 
			and gameloop.p2.occlude == 0 and self.inputLock then
			instructions = instructions .. "\n" .. gameloop:kills()
			self:targetPopup()
		end

		if gameloop.p1.skips > 0 and #gameloop.p1.hand > 0 and gameloop.p1.kills == 0 and gameloop.p2.kills == 0 then
			self:skipPopup()
		end

		self:refreshBags()
		self.inputLock = false

	elseif gameloop.Gamestate == 10 then
		self.targetPopupOn = false
		
		if gameloop.p1.skips > 0 and #gameloop.p1.hand > 0 and self.inputLock then
			gameloop:playerSkip()
			self:skipPopup()
			gameGUI:refreshBags()
		end
		--no skips or hand
		if gameloop.p1.skips == 0 or #gameloop.p1.hand == 0 then
			--deal with the rest
			gameloop:postkills()
			gameGUI:refreshBags()
		end
		self.inputLock = false

	elseif gameloop.Gamestate == 11 then
		self.skipPopupOn = false
		gameGUI:setButtonActive(shopButtons, true)
		--instructions = instructions .. " Select purchase from shop?"
		keepReroll.text = "Keep\nMoney"
		--handle shopping one at a time
		if shop.firstPick == gameloop.p2 and shop.firstGone == false then
			--p2 is first, let them go
			gameloop:shopping()
			gameGUI:refreshShop()
			gameGUI:refreshBags()
		elseif shop.firstPick == gameloop.p1 and shop.firstGone == false and self.inputLock then
			--p1 is first, wait for input lock
			gameloop:shopping()
			gameGUI:refreshShop()
			gameGUI:refreshBags()
		elseif shop.firstGone then
			--second shopper
			if shop.firstPick == gameloop.p2 and self.inputLock then
				--p1 goes second, wait for input
				gameloop:shopping()
				gameGUI:refreshShop()
				gameGUI:refreshBags()
			elseif shop.firstPick == gameloop.p1 then
				--p2 goes second
				gameloop:shopping()
				gameGUI:refreshShop()
				gameGUI:refreshBags()
			end
		end

		self.inputLock = false

	elseif gameloop.Gamestate == 12 then
		gameloop:checkForWinner()
		gameGUI:setButtonActive(shopButtons, false)
	end

	if gameloop.Gamestate == -1 then
		--gameover, not already game over animating
		print("Gameover")
		gameGUI:setAnimation("Gameover", 3)
	end
end

function gameGUI:fetchOutcomes()
	for i = 1, 5, 1 do
		outcomeButtons[i].text = gameloop.p1.outcomes[i]
		outcomeButtons[i].active = true
	end
	for i = 1, 5, 1 do
		enemyOutcomeButtons[i].text = gameloop.p2.outcomes[i]
	end
end

function gameGUI:printDiceInfo(d, x, y)
	if d == nil or d == "-" then
		return
	end

	love.graphics.setColor(unpack(defaultColor))
	love.graphics.rectangle("fill",x,y,boxX * 4,boxX)
	graphics:printDicePlate(d, x, y, 1)

	--all sides on the dice
	for xOffset = 1, 6, 1 do
		graphics:printOutcome(
			dice[d][xOffset],
			x + boxX + (boxX/2) * (xOffset-1), 
			y,
			0.5
		)
	end

	love.graphics.setColor(0,0,0,1)
	love.graphics.print(d,font,x + boxX,y + boxX/2)
end

function gameGUI:printShopButtons()
	--shop buttons
	local shopY = boxX/2
	local shopBX = boxX * 4.5
	--I know I know its all over the place I'll sort it out some other time
	local cost = {1,2,4,8,16}
	for xOffset, shopB in ipairs(shopButtons) do
		shopB.last = shopB.now
		--check if you can afford it
		if gameloop.p1.wallet < cost[xOffset] or shopB.text == nil then
			shopB.active = false
		end
		--check if hovering mouse
		local hovering = mouseX > shopBX and mouseX < shopBX + boxX
			and mouseY > shopY and mouseY < shopY + boxX
		shopB.now = love.mouse.isDown(1)
		if hovering and shopB.active then
			love.graphics.setColor(unpack(hotButtonColor))
			if shopB.now and not shopB.last then
				shopB.fn()
			end
		elseif shopB.active == false then
			love.graphics.setColor(inactiveButtonColor)
		else
			love.graphics.setColor(unpack(defaultColor))
		end
		--draw the box
		love.graphics.rectangle("fill",shopBX,shopY,boxX,boxX)
		--write in text on shop button
		if shopB.text == nil then
			love.graphics.setColor(textColour)
			love.graphics.print("-",font,shopBX,shopY)
		else
			graphics:printDicePlate(shopB.text, shopBX, shopY, 1)
			love.graphics.setColor(textColour)
		end
		--write in price under shop button
		love.graphics.setColor(defaultColor)
		---@diagnostic disable-next-line: param-type-mismatch
		love.graphics.print(shopCosts[xOffset],font,shopBX,0)--shopY+boxX)

		if hovering then
			--extra info on top 
			gameGUI:printDiceInfo(shopB.text, mouseX, boxX * 1.5)
		end

		shopBX = shopBX + boxX
	end
	--Label shop
	love.graphics.setColor(defaultColor)
	love.graphics.print(string.format("Shop\n%i", #gameloop.shop.deck),font,shopBX,shopY)
end

function gameGUI:printBagButtons(bags, x, y, w)
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

function gameGUI:printBagContents(bag, bagname)
	local margin = boxX/3
	local contents_x = (boxX + margin) * 6 + margin
	local total_height = 0 
	if #bag > 0 then
		total_height = (boxX + margin) * math.floor((#bag-1)/6 + 1) + margin
	else
		total_height = boxX + 2*margin
	end

	local xOffset = (windowW - contents_x) / 2
	local yOffset = (windowH - total_height)/2

	local mx,my = love.mouse.getPosition()

	--black behind the dice
	love.graphics.setColor(0.1,0.1,0.1,1)
	love.graphics.rectangle(
		"fill",
		xOffset - margin,
		yOffset - margin - boxX,
		contents_x + 2*margin,
		total_height + 2*margin + boxX
	)
	love.graphics.setColor(defaultColor)
	love.graphics.rectangle(
		"fill",
		xOffset,
		yOffset - boxX,
		contents_x,
		total_height + boxX
	)

	--write the text in
	love.graphics.setColor( 0, 0, 0, 1.0)
	love.graphics.print(bagname, title, xOffset + boxX,yOffset - boxX + margin)
	
	for d = 1, #bag, 1 do
		local dx = xOffset + margin + (((boxX + margin) * (d-1) + 1) % (contents_x-margin))
		local dy = yOffset + margin + (boxX + margin) * math.floor((d-1)/6)

		love.graphics.setColor(defaultColor)
		graphics:printDicePlate(bag[d], dx, dy, 1)
		local hot = mx > dx and mx < dx + boxX 
				and my > dy and my < dy + boxX
		if hot then
			gameGUI:printDiceInfo(bag[d], mx, dy - boxX)
		end
	end
end

function gameGUI:printBagContentsPopup(popupInfo, player)
	local margin = boxX/3
	local contents_x = (boxX + margin) * 6 + margin
	local total_height = 0 
	if #popupButtons > 0 then
		total_height = (boxX + margin) * math.floor((#popupButtons-1)/6 + 1) + margin
	else
		total_height = boxX + 2*margin
	end

	local xOffset = (windowW - contents_x) / 2
	local yOffset = (windowH - total_height)/2

	local mx,my = love.mouse.getPosition()

	--black behind the dice
	love.graphics.setColor(0.1,0.1,0.1,1)
	love.graphics.rectangle(
		"fill",
		xOffset - margin,
		yOffset - margin - boxX,
		contents_x + 2*margin,
		total_height + 2*margin + boxX
	)
	love.graphics.setColor(defaultColor)
	love.graphics.rectangle(
		"fill",
		xOffset,
		yOffset - boxX,
		contents_x,
		total_height + boxX
	)

	--write the text in
	love.graphics.setColor( 0, 0, 0, 1.0)
	love.graphics.print(popupInfo, title, xOffset + boxX,yOffset - boxX + margin)
	
	for d,dice in ipairs(popupButtons) do
		dice.last = dice.now

		local dx = xOffset + margin + (((boxX + margin) * (d-1) + 1) % (contents_x-margin))
		local dy = yOffset + margin + (boxX + margin) * math.floor((d-1)/6)

		love.graphics.setColor(defaultColor)
		graphics:printDicePlate(dice.text, dx, dy, 1)
		local hot = mx > dx and mx < dx + boxX 
				and my > dy and my < dy + boxX
		
		dice.now = love.mouse.isDown(1)
		if hot then
			gameGUI:printDiceInfo(dice.text, mx, dy - boxX)
			--color = hotButtonColor
			if dice.now and not dice.last then
				dice.fn()
			end
		end
	end
end

function gameGUI:printHand(hand, offsetHandX, player)
	for yOffset, diceH in ipairs(hand) do
		--where diceH is the button holding the dice
		local handButtY = boxX * 2.5 + boxX*(yOffset-1)
		diceH.last = diceH.now

		--Dice type box
		love.graphics.setColor(unpack(inactiveButtonColor))
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
		--love.graphics.print(diceH.text,font,offsetHandX,handButtY)

		local highlighter = false
		--all sides on the dice in hand
		for xOffset = 1, 6, 1 do
			--lhighlight dice outcome if its that dice's outcome
			if highlighter == false and player.outcomes[yOffset] == dice[diceH.text][xOffset] then
				--first match 
				love.graphics.setColor(hotButtonColor)
				highlighter = true
			else
				love.graphics.setColor(inactiveButtonColor)
			end
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
		elseif diceH.active == false then
			love.graphics.setColor(inactiveButtonColor)
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
		if gameloop.Gamestate == 2 then
			love.graphics.setColor(textColour)
			love.graphics.print(
				"Swap",
				font,
				swapButtonX + 4,
				handButtY + 2
			)
		elseif gameloop.Gamestate == 4 then
			love.graphics.setColor(textColour)
			love.graphics.print(
				"Reroll",
				font,
				swapButtonX + 4,
				handButtY + 2
			)
		end
	end
end

function gameGUI:printOutcomes(outcomes, x, y)
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
		elseif pOutcomeB.active == false then
			love.graphics.setColor(inactiveButtonColor)
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

function gameGUI:printKeepRerollButton(rButton,keepRerollButtonX,y)
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
	elseif rButton.active == false then
		love.graphics.setColor(inactiveButtonColor)
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

function gameGUI:printPopupMenu()
	local button_width = windowW * (1/3)
	local popup_button_height = boxX
	local yMargin = boxX/3
	
	local total_height = (popup_button_height + yMargin) * #popupButtons
	
	local yOffset = 0
	
	local mx,my = love.mouse.getPosition()
	
	for i, button in ipairs(popupButtons) do
		button.last = button.now
	
		local bx = (windowW / 2) - (button_width / 2)
		local by = (windowH / 2) - (total_height / 2) + yOffset

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
		
		local textW = title:getWidth(button.text)
		local textH = title:getHeight(button.text)
		
		love.graphics.print(
			button.text, 
			title, 
			(windowW / 2) - (textW / 2), 
			by + (textH / 2) - 6
		)
		yOffset = yOffset + (popup_button_height + yMargin)
	end
end

function gameGUI:printInfoScreen()
	--needs to be a little smaller so it doesnt go off screen
	local info_width = windowW * (1/3)
	local total_height = (boxX * 3/4) * #outcomes
	
	local yOffset = 0
	for i = 1, #outcomes, 1 do
		local bx = (windowW / 3) - (boxX / 2)
		local by = (windowH / 2) - (total_height / 2) + yOffset
		--draw the rectangle
		local color = defaultColor

		love.graphics.setColor(unpack(color))
		love.graphics.rectangle(
			"fill",
			bx,
			by,
			info_width,
			boxX * 3/4
		)love.graphics.setColor(textColour)
		love.graphics.rectangle(
			"line",
			bx,
			by,
			info_width,
			boxX * 3/4
		)
		
		--write the text in
		love.graphics.setColor(textColour)
		local textW = font:getWidth(outcomes[i][2])
		local textH = font:getHeight(outcomes[i][2])
		
		love.graphics.print(
			outcomes[i][2], 
			font, 
			(windowW / 2) - (textW / 2), 
			by + (textH / 2) - 6
		)
		yOffset = yOffset + (boxX * 3/4)


		love.graphics.setColor(1,0,0,1)
		graphics:printOutcome(outcomes[i][1], bx + 3, by, 3/4)
	end
end

function gameGUI:printInfoButton(bx, by)
	self.infoButton.last = self.infoButton.now

	local mx,my = love.mouse.getPosition()

	--draw the rectangle
	local color = defaultColor
	local hot = mx > bx and mx < bx + boxX 
			and my > by and my < by + boxX
	
	self.infoButton.now = love.mouse.isDown(1)
	if hot then
		color = hotButtonColor
		if self.infoButton.now and not self.infoButton.last then
			self.infoButton.fn()
		end
	end

	love.graphics.setColor(unpack(color))
	love.graphics.rectangle(
		"fill",
		bx,
		by,
		boxX,
		boxX
	)

	--write the text in
	love.graphics.setColor(textColour)
	
	local textW = font:getWidth(self.infoButton.text)
	local textH = font:getHeight(self.infoButton.text)
	
	love.graphics.print(
		self.infoButton.text, 
		title, 
		bx + boxX/2 -  (textW / 2) - 2, 
		by + boxX/2 - (textH / 2) - 6
	)
end

--TODO make this much nicer
function gameGUI:printEndgame()
	--cover about a third of the screen
	local wid = windowW/3
	local hei = windowH/3
	love.graphics.setColor(0.1,0.1,0.1,1)
	love.graphics.rectangle(
		"fill",
		wid,
		hei,
		wid,
		hei
	)
	--write the text in
	love.graphics.setColor( 1, 1, 1, 1.0)
	love.graphics.print(
		"Auto Rolling out Endgame\n" .. 
		"Round ".. gameloop.round_counter, 
		title, 
		wid + boxX/3, 
		hei + boxX
	)
end

--TODO make this much nicer
function gameGUI:printGameoverScreen()
	local wid = windowW - boxX * 2
	local hei = windowH - boxX * 2
	love.graphics.setColor(0.1,0.1,0.1,1)
	love.graphics.rectangle(
		"fill",
		boxX,
		boxX,
		wid,
		hei
	)
	--write the text in
	love.graphics.setColor( 1, 1, 1, 1.0)
	love.graphics.print(
		"Gameover\n" .. 
		gameloop:checkForWinner(), 
		title, 
		3 * boxX, 
		3 * boxX
	)
end

function gameGUI:draw()
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
	love.graphics.print(string.format("%s life: %i", gameloop.p2.name, gameloop.p2:getLife()),font,windowW - 4*boxX,windowH - boxX/2)

	--print player plates
	--player 1
	graphics:printPlayer(gameloop.p1.plate, 0, boxX*8, 1)
	--player 2
	graphics:printPlayer(gameloop.p2.plate, windowW-boxX*4.5, boxX*8, 1)

	--print instructions at bottom
	love.graphics.setColor(defaultColor)
	love.graphics.print(instructions,font, 3.75*boxX, 9 * boxX)

	--print info button
	self:printInfoButton(windowW-4*boxX, boxX/2)

	--Player on the left hand of the screen
	--player bag buttons
	local bagX = boxX/2
	local bagBY = boxX * 1.5
	local bagWidth = boxX * 1.5
	self:printBagButtons(bagButtons, bagX, bagBY, bagWidth)

	--player 1 hand buttons
	local offsetHandX = boxX * 3.75
	self:printHand(handButtons, offsetHandX,gameloop.p1)

	--player outcome buttons
	local pOutcomeY = boxX * 7.5
	local pOutcomeBX = boxX * 3.25
	self:printOutcomes(outcomeButtons, pOutcomeBX, pOutcomeY)

	--player keep reroll button
	self:printKeepRerollButton(keepReroll, 8.25*boxX, 7.5*boxX)

	--Enemy on right side of the screen
	--enemy bag buttons
	bagX = windowW - boxX * 2
	bagBY = boxX * 1.5
	self:printBagButtons(enemyBagButtons, bagX, bagBY, bagWidth)

	--enemy hand buttons
	offsetHandX = boxX * 10.5
	self:printHand(enemyHandButtons, offsetHandX, gameloop.p2)

	--enemy outcome buttons
	local eOutcomeY = pOutcomeY
	local eOutcomeBX = boxX * 10
	self:printOutcomes(enemyOutcomeButtons, eOutcomeBX, eOutcomeY)

	--enemy keep reroll button
	self:printKeepRerollButton(enemyKeepReroll, 15*boxX, 7.5*boxX)

	--shop buttons
	self:printShopButtons()

	--kill meters
	
	--popup for swap in
	if self.swapInPopupOn == true then
		--show it
		--self:printPopupMenu()
		self:printBagContentsPopup("Pick who to swap in", gameloop.p1)
		if #gameloop.p1.deck == 0 then
			
		end
	end

	--popup for empower
	if self.empowerPopupOn == true then
		--show it
		self:printPopupMenu()
	end

	--popup for revive
	if self.revivePopupOn == true then
		--show it
		self:printBagContentsPopup("Revive from your Grave", gameloop.p1)
	end

	--popup for steal revive
	if self.stealRevivePopupOn == true then
		--show it
		self:printBagContentsPopup("Steal from Enemy Grave", gameloop.p1)
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

	if self.bagContents == nil then
		--don't print a bags contents duh
	elseif self.bagContents == "p1Deck" then
		self:printBagContents(gameloop.p1.deck, gameloop.p1.name.."'s Deck")
	elseif self.bagContents == "p2Deck" then
		self:printBagContents(gameloop.p2.deck, gameloop.p2.name.."'s Deck")
	elseif self.bagContents == "p1Grave" then
		self:printBagContents(gameloop.p1.grave, gameloop.p1.name.."'s Grave")
	elseif self.bagContents == "p2Grave" then
		self:printBagContents(gameloop.p2.grave, gameloop.p2.name.."'s Grave")
	elseif self.bagContents == "p1Discard" then
		self:printBagContents(gameloop.p1.discard, gameloop.p1.name.."'s Discard")
	elseif self.bagContents == "p2Discard" then
		self:printBagContents(gameloop.p2.discard, gameloop.p2.name.."'s Discard")
	end

	--endgame autorollout
	if gameloop.running == 2 then
		--endgame splash
		self:printEndgame()
	end
	--info on outcomes
	if self.infoScreenOn then
		self:printInfoScreen()
	end
	--gameover splash
	if self.gameoverScreenOn then
		self:printGameoverScreen()
	end
end