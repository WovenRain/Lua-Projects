require("playerState")
require("shop")

gameloop = {}

---- 0 INITIALISATION
--get player decks
--make shop, p1, p2
function gameloop:initialisation(p1Name, p1Input, p2Name, p2Input)
    self.round_counter = 0
    self.running = 1
    self.income = 2

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

function gameloop:getPlayer()
    return self.p1
end

function gameloop:getPlayer2()
    return self.p2
end

function gameloop:getShop()
    return self.shop
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
    if self.running == 1 then
        self.p1:handleSwap()
        self.p2:handleSwap()
    end
    print()

    print("player has "..self.p1.rerolls.." rerolls")
    print("enemy has "..self.p2.rerolls.." rerolls")
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
    print("Skipping empowers")
    print("skipping - popup needed")
    --TODO popup GUI for empowers
    --self.p1:handleEmpowers()
    --self.p2:handleEmpowers()

    self.Gamestate = 7
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
end
---- 8 PREKILLS
--let players handle revives
--pick first shopper before kills are set back to 0
--show kill count
function gameloop:prekills()
    --let players handle revives
    print()
    print("Prekill revives")
    print("skipping - popup needed")
    --TODO popup for revives
    --self.p1:handleRevives(self.p2)
    --self.p2:handleRevives(self.p1)

    --pick first shopper before kills are set back to 0
    self.shop:pickFirst(self.p1, self.p2)

    --show kill count
    print(string.format("%s has %i kills", self.p1.name, self.p1.kills))
    print(string.format("%s has %i kills", self.p2.name, self.p2.kills))

    self.Gamestate = 9
end
---- 9 KILLS
--roll for death, or target
function gameloop:kills()
    --roll for death
    print()
    print("deaths - button input needed")

    --TODO turn handleKills into handle kill by turning while loop into if
    --itterate over this, if no more kills -> self.Gamestate = 10

    self.p1:handleKills(self.p2)
    self.p2:handleKills(self.p1)

    self.Gamestate = 10
end
---- 10 POSTKILLS
--check skips then send back to deck
--move hands to discard
--generate income
function gameloop:postkills()
    --check skips then send back to deck
    print()
    print("skips - button input needed")
    self.p1:handleSkips()
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
---- 11 SHOP
--players buy from shop
function gameloop:shopping()
    --if shop empty or refused - endgame TODO
    if #self.shop.run == 0 then
        print()
        self.running = 2
    else
        --players buy from shop
        --TODO make this work properly
        self.shop:handleShop(self.p1, self.p2)
    end
    if shop.allGone == true then
        self.Gamestate = 12
    end
end
--if shop empty or refused - endgame
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

    self.Gamestate = 1
end
--