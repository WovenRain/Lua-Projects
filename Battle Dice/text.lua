require("playerState")
require("shop")

--INITIALISATION
--game state
round_counter = 0
running = 1
income = 2
shop:build()

--get player decks
player = playerState:new()
player2 = playerState:new()

print("starting game")
print("Please enter player 1 name: ")
--player:starting(io.read(), "1")
player:starting("1", "1")

print("Please enter player 2 name: ")
--player2:starting(io.read(), "random")
player2:starting("R", "random")

while running < 3 do
    --ROUND START
    round_counter = round_counter + 1
    print("-------NEW ROUND-------")
    print(round_counter)
    --new Round, set things to 0
    player:newRound()
    player2:newRound()

    --draw hands 
    print("players draw their hands")
    player:drawHand()
    player2:drawHand()

    --show the player/s
    print(string.format("%s %s", player.name, player:handString()))
    print(string.format("%s %s", player2.name, player2:handString()))

    --SWAP OR REROLL
    --choose swap or reroll
    if running == 1 then
        player:handleSwap()
        player2:handleSwap()
    end
    print()

    --ROLL HAND
    --roll the dice
    print("outcomes of dice")
    player:rollHand()
    player2:rollHand()
    player:countRerolls()
    player2:countRerolls()

    --show player outcomes
    print()
    print(player.name .. " has " .. player:outcomeString())
    print(player2.name .. " has " .. player2:outcomeString())

    --REROLLS
    --if either player had rerolls, start loop for more rerolls
    while player.rerolls > 0 or player2.rerolls > 0 do
        player:handleRerolls()
        player2:handleRerolls()

        --mostly/all for debugging
        print()
        print(player.name .. " has " .. player:outcomeString())
        print(player2.name .. " has " .. player2:outcomeString())
    end

    --MEASURE OUTCOMES
    --calculate outcomes of dice
    player:calculate()
    player2:calculate()

    --PREFIGHT
    --players choose what to empower
    player:handleEmpowers()
    player2:handleEmpowers()

    --FIGHT
    --calculate kills
    player:measureKills(player2)
    player2:measureKills(player)

    --PREKILLS
    --let players handle revives
    player:handleRevives(player2)
    player2:handleRevives(player)

    --pick first shopper before kills are set back to 0
    shop:pickFirst(player, player2)

    --show kill count
    print(string.format("%s has %i kills", player.name, player.kills))
    print(string.format("%s has %i kills", player2.name, player2.kills))

    --KILLS
    --roll for death
    player:handleKills(player2)
    player2:handleKills(player)

    --POSTKILLS
    --check skips then send back to deck
    player:handleSkips()
    player2:handleSkips()

    --move hands to discard
    player:discardHand()
    player2:discardHand()

    --generate income
    if running == 1 then
        player:getIncome(income)
        player2:getIncome(income)
    end
    print()

    --FOR DEBUG
    print("-------DEBUG STATUS-------")
    print("Round " .. round_counter)
    print(player.name .. " has " .. player:stateString())
    print(player2.name .. " has " .. player2:stateString())
    print("-------DEBUG STATUS-------")

    --SHOP
    --if shop empty or refused - endgame
    if #shop.run == 0 then
        print()
        running = 2
    else
        --players buy from shop
        shop:handleShopping(player, player2)
    end
    --TODO endgame means no more choices
    
    --CHECK FOR WINNER
    --if playerdeck + discard < 5, they lose
    if player:isAlive() == false and player2:isAlive() == false then
        print("Draw!!")
        break
    elseif player:isAlive() == false then
        print(string.format("%s wins!!", player2.name))
        break
    elseif player2:isAlive() == false then
        print(string.format("%s wins!!", player.name))
        break
    end
end