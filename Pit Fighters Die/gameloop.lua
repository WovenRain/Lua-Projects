require("playerState")
require("shop")

gameloop = {}

rev = 1

---- 0 INITIALISATION
--get player decks
--make shop, p1, p2
function gameloop:initialisation(p1Name, p1Input, p2Name, p2Input)
    self.round_counter = 0
    self.running = 1
    self.income = 2

    self.p1Swapin = false
    self.p2Swapin = false

    --get player decks
    self.p1 = playerState:new()
    self.p2 = playerState:new()

    print("starting game")
    print("Please enter player 1 name: ")
    --player:starting(io.read(), "1")
    self.p1:starting(p1Name, p1Input)

    print("Please enter player 2 name: ")
    --player2:starting(io.read(), "random")
    self.p2:starting(p2Name, p2Input)

    self.shop = shop
    self.shop:build()
    self.Gamestate = 2

    --immediatly jump into first round
    self:startRound()
end

---- 1 ROUND START--     Loop from here
--draw hands 
--show the player/s
function gameloop:startRound()
    self.round_counter = self.round_counter + 1
    print("-------NEW ROUND-------")
    print(self.round_counter)
    --new Round, set things to 0
    self.p1:newRound()
    self.p2:newRound()

    --draw hands 
    print("players draw their hands")
    self.p1:drawHand()
    self.p2:drawHand()

    --show the player/s
    print(string.format("%s %s", self.p1.name, self.p1:handString()))
    print(string.format("%s %s", self.p2.name, self.p2:handString()))

    self.Gamestate = 2
end
---- 2 SWAP OR REROLL
--choose swap or reroll
function gameloop:swapOrReroll()
    self.p1Swapin = false
    self.p2Swapin = false

    if self.running == 1 then
        self.p1Swapin = self.p1:handleSwapOrReroll()
        self.p2Swapin = self.p2:handleSwapOrReroll()
    end
    print()

    print("player has "..self.p1.rerolls.." rerolls")
    print("enemy has "..self.p2.rerolls.." rerolls")

    if self.p1Swapin == false then
        self.Gamestate = 3
    elseif #self.p1.deck > 0 then
        gameGUI:swapInPopup(self.p1)
        self.Gamestate = 25
    end
end
---- 2.5 SWAP IN
--deal with player popup choice
function gameloop:swapIn()
    if self.p1Swapin then
        self.p1:swapIn()
    end
    if self.p2Swapin then
        self.p2:swapIn()
    end
    self.Gamestate = 3
end
---- 3 ROLL HAND
--roll the dice
--show player outcomes
function gameloop:rollHand()
    print("outcomes of dice")
    self.p1:rollHand()
    self.p2:rollHand()
    self.p1:countRerolls()
    self.p2:countRerolls()

    print("player has "..self.p1.rerolls.." rerolls")
    print("enemy has "..self.p2.rerolls.." rerolls")

    --show player outcomes
    print()
    print(self.p1.name .. " has " .. self.p1:outcomeString())
    print(self.p2.name .. " has " .. self.p2:outcomeString())

    self.Gamestate = 4
    print("finished rolling hands")
end
---- 4 REROLLS
--if either player had rerolls, start loop for more rerolls
function gameloop:rerolls()
    print("Gameloop got to rerolls")
    print("player has "..self.p1.rerolls.." rerolls")
    print("enemy has "..self.p2.rerolls.." rerolls")
    --if either player had rerolls, start loop for more rerolls
    if self.p1.rerolls > 0 or self.p2.rerolls > 0 then
        print("handling rerolls")
        self.p1:handleReroll()
        self.p2:handleReroll()

        --mostly/all for debugging
        print()
        print(self.p1.name .. " has " .. self.p1:outcomeString())
        print(self.p2.name .. " has " .. self.p2:outcomeString())
    end
    --just took away rerolls, move on
    if self.p1.rerolls == 0 and self.p2.rerolls == 0 then
        self.Gamestate = 5
        print("exiting rerolls")
    end
end
---- 5 MEASURE OUTCOMES
--calculate outcomes of dice
function gameloop:measureOutcomes()
    --calculate outcomes of dice
    print()
    print("measuring outcomes")
    self.p1:calculate()
    self.p2:calculate()

    self.Gamestate = 6
end
---- 6 PREFIGHT
--players choose what to empower
function gameloop:prefight()
    --players choose what to empower
    print()
    print("Empowers")
    print("player has "..self.p1.empowers.." empowers")
    print("enemy has "..self.p2.empowers.." empowers")
    if self.p1.empowers > 0 then
        self.p1:handleEmpower()
    end
    if self.p2.empowers > 0 then
        self.p2:handleEmpower()
    end
    --just took away rerolls, move on
    if self.p1.empowers == 0 and self.p2.empowers == 0 then
        self.Gamestate = 7
        print("exiting Empowers")
    end
end
---- 7 FIGHT
--calculate KILLS, and outcomes
function gameloop:fight()
    --calculate kills
    print()
    print("fighting now")
    self.p1:measureKills(self.p2)
    self.p2:measureKills(self.p1)

    self.Gamestate = 8
    rev = 1
end
---- 8 PREKILLS
--let players handle revives
--pick first shopper before kills are set back to 0
--show kill count
function gameloop:prekills()
    --let players handle revives
    print()
    print("Prekill revives")
    
    --handle one at a time like rerolls and empowers
    if rev == 1 then
        self.p1:handleRevive(self.p2)
        rev = 2
        gameGUI.inputLock = true -- ?? still doesnt work
    elseif rev == 2 then
        self.p2:handleRevive(self.p1)
        rev = 1
    end

    --pick first shopper before kills are set back to 0
    self.shop:pickFirst(self.p1, self.p2)

    --show kill count
    print(string.format("%s has %i kills", self.p1.name, self.p1.kills))
    print(string.format("%s has %i kills", self.p2.name, self.p2.kills))

    if self.p1.revives > 0 or self.p2.revives > 0 then
        --do this again

        --if there's nothing in the grave just go
        if #self.p1.grave == 0 then
            self.p1.revives = 0
        end
        if #self.p2.grave == 0 then
            self.p2.revives = 0
        end
    else
        self.Gamestate = 9
    end
end
---- 9 KILLS
--roll for death, or target
function gameloop:kills()
    --roll for death
    print()
    print("deaths - button input needed")

    local s = ""

    --TODO turn handleKills into handle kill by turning while loop into if
    --handle one target at a time like rerolls and empowers
    --itterate over this

    s = self.p1:handleKill(self.p2)
    s = self.p2:handleKill(self.p1).."  ...  "..s

    -- if no more kills -> self.Gamestate = 10
    if self.p1.kills == 0 and self.p2.kills == 0 then
        self.Gamestate = 10
    end
    return s
end
---- 10 POSTKILLS
--check skips then send back to deck
--move hands to discard
--generate income
function gameloop:postkills()
    --check skips then send back to deck
    print()
    print("enemy skips and income after player decides skips")

    self.p2:handleSkips()

    --move hands to discard
    self.p1:discardHand()
    self.p2:discardHand()

    --generate income
    if self.running == 1 then
        self.p1:getIncome(self.income)
        self.p2:getIncome(self.income)
    end

    print()

    --FOR DEBUG
    print("-------DEBUG STATUS-------")
    print("Round " .. self.round_counter)
    print(self.p1.name .. " has " .. self.p1:stateString())
    print(self.p2.name .. " has " .. self.p2:stateString())
    print("-------DEBUG STATUS-------")

    self.Gamestate = 11
end
--player skip one at a time
function gameloop:playerSkip()
    self.p1:handleSkip()
end
---- 11 SHOP
--players buy from shop
function gameloop:shopping()
    --if shop empty - endgame
    if #self.shop.run == 0 then
        print("Endgame")
        self.running = 2
        self.Gamestate = 12
        --thinking about this it'd cause issues, 
        --still giving popups and waiting for player input
        --would have to put more checks elsewhere
        self.p1.type = "random"
        self.p2.type = "random"
    else
        --players buy from shop
        self.shop:handleShop(self.p1, self.p2)
    end
    if shop.allGone == true then
        self.Gamestate = 12
    end
end
---- 12 CHECK FOR WINNER
function gameloop:checkForWinner()
    --if playerdeck + discard < 5, they lose
    if self.p1:isAlive() == false and self.p2:isAlive() == false then
        print("Draw!!")
        self.Gamestate = -1
        return "Draw!!"
    elseif self.p1:isAlive() == false then
        print(string.format("%s wins!!", self.p2.name))
        self.Gamestate = -1
        return string.format("%s wins!!", self.p2.name)
    elseif self.p2:isAlive() == false then
        print(string.format("%s wins!!", self.p1.name))
        self.Gamestate = -1
        return string.format("%s wins!!", self.p1.name)
    end
    --if shop empty - endgame
    if #self.shop.run == 0 then
        print("Endgame")
        self.running = 2
        self.Gamestate = 12
        --thinking about this it'd cause issues, 
        --still giving popups and waiting for player input
        --would have to put more checks elsewhere
        self.p1.type = "random"
        self.p2.type = "random"
    end

    self.Gamestate = 1
end
--