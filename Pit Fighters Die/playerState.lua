require("dice")
require("BasicAI")

playerState = {}

--Move list
--[[
    Move Types
    Attack
        Add 1 to attack
    Double Atk
        Add 2 to attack
    Defend
        Add 1 to defend
    Double Def
        Add 2 to defend
    Revive
        Add 1 to revive
    Target
        Turn kills to targeted kills
    Skip
        after kills, choose 1 on team to go back in deck
        as opposed to into discard
    Reroll
        Reroll this dice
        or maybe another? idk
    Half Revive
        If two in team, add 1 revive
    ------------------------------
    Weaken
        -2 to enemy defend
    Double Income
        *2 to income, stacks
    Add to Income
        +1 to income, before multiples
    Empower
        Double attack or defend
    Occlude
        Cancle enemy targets
    Safe
        Doesnt get die if killed
        Put directly back into deck?
    Substitute
        One killed goes into discard not grave
    Steal Revive
        If enemy revives, take from their grave
    Attack and Defend
    Attack and Target
]]

--honestly no idea how this works
--essential for instantiating multiple instances
function playerState:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function playerState:starting(givenName, playerType, playerPlate)
    --generate player starting deck
    self.deck = {
        "Fighter", "Fighter",
        "Rogue", "Rogue",
        "Cleric",
        "Wizard", "Wizard",
        
        "Mage",
        "Squire",
        "Necromancer",
        --[[
        "Mage", "Mage",
        "Squire", "Squire",
        "Spy", "Assassin", "Archer", 
        "Bard", "Sorcerer", "Knight",
        "Tank", "Merchant", "Banker"--]]
    }
    --AI or player controlled
    self.type = playerType
    
    self.plate = playerPlate
    self.name = givenName

    --initial grave and discard are empty
    self.grave = {}
    self.discard = {}
    self.hand = {}
    self.attacks = 0
    self.defends = 0
    self.kills = 0
    self.revives = 0
    self.halfrev = 0
    self.wallet = 0
    self.rerolls = 0
    self.targets = 0
    self.skips = 0
    self.steals = 0
    self.weakens = 0
    self.substitutes = 0
    self.occlude = 0
    self.empowers = 0
    self.atkMult = 1
    self.defMult = 1
    self.incomeMult = 1
    self.addIncome = 0
    self.outcomes = {}
    self.choices = {}
    self.choiceMade = nil
    self.choiceType = nil
    math.randomseed(os.time())
end

function playerState:newRound()
    self.attacks = 0
    self.defends = 0
    self.kills = 0
    self.revives = 0
    self.halfrev = 0
    self.rerolls = 0
    self.targets = 0
    self.skips = 0
    self.steals = 0
    self.weakens = 0
    self.substitutes = 0
    self.occlude = 0
    self.empowers = 0
    self.atkMult = 1
    self.defMult = 1
    self.incomeMult = 1
    self.addIncome = 0
    self.swapOut = nil
    self.outcomes = {}
    self.choices = {}
    self.choiceType = nil
    self.choiceMade = nil

    --[[
        ChoiceTypes
        
        revive
        revive steal
        swap out
        swap in
        reroll
        empower
        skip
        target
    ]]
end

function playerState:getPlayerInput()
    if self.type == "cmd" then
        return io.read()
    elseif self.type == "gui" then
        return self.choiceMade
    elseif self.type == "1" then
        return 1
    elseif self.type == "random" then
        return math.random(1, #self.choices)
    elseif self.type == "basic" then
        return BasicAI:getChoice(self)
    end
end

--draw 5 random dice from deck
function playerState:drawHand()
    --if deck smaller than 5 -> add discard to deck after taking whats left
    if #self.deck < 5 then
        --put all those in hand
        local left = 5 - #self.deck
        for i = 1, #self.deck, 1 do
            --take all from deck
            table.insert(self.hand, table.remove(self.deck, 1))
        end

        --add discard to deck
        self:discardBackToDeck()
        for i = 1, left, 1 do
            --take 5 - what you took, from deck, randomly
            table.insert(self.hand, table.remove(self.deck, math.random(1, #self.deck)))
        end
    else
        --at least 5 in deck
        for i = 1, 5, 1 do
            --pick 5 random from deck
            table.insert(self.hand, table.remove(self.deck, math.random(1, #self.deck)))
        end
    end
end

function playerState:discardBackToDeck()
    for i = 1, #self.discard, 1 do
        --take all from discard
        table.insert(self.deck, table.remove(self.discard, 1))
    end
end

function playerState:discardHand()
    for i = 1, #self.hand, 1 do
        --take all from hand to discard
        table.insert(self.discard, table.remove(self.hand, 1))
    end
end

function playerState:sendToGrave(x)
    --send hand[x] to grave, unless substitute
    local s = ""
    if x < #self.hand + 1 then
        if self.substitutes > 0 then
            print(string.format("%s had a substitute. %s was saved and put in deck", self.name, self.hand[x]))
            s = string.format("%s's %s was substituted and put in deck", self.name, self.hand[x])
            self.substitutes = self.substitutes - 1
            table.insert(self.deck, table.remove(self.hand, x))
        else
            print(string.format("%s's %s sent to grave", self.name, self.hand[x]))
            s = string.format("%s's %s sent to grave", self.name, self.hand[x])
            table.insert(self.grave, table.remove(self.hand, x))
        end
    else
        print("Miss!")
        s = string.format("%s had a Miss!", self.name)
    end
    return s
end

function playerState:getIncome(x)
    self.wallet = self.wallet + (x + self.addIncome) * self.incomeMult
end

--for one at a time GUI
function playerState:handleRevive(opponent)
    if self.revives > 0 then
        self.choices = {}
        self.choiceType = "revive"
        --choose revives
        --if opponent has steal -> steal revive
        if self.revives > 0 and opponent.steals > 0 and #self.grave > 0 then
            --opponent steals from self grave
            opponent.choices = {}
            opponent.choiceType = "steal revive"
            --revive steals
            print(string.format("%s has a Steal Revive", opponent.name))
            print("Who would you like to Revive Steal?")
            --list all in player grave
            for i = 1, #self.grave, 1 do
                print(string.format("%i: %s", i, self.grave[i]))
                --add to choices
                opponent.choices[i] = self.grave[i]
            end
            --opponent choosez
            local r = tonumber(opponent:getPlayerInput())
            if r > #opponent.grave then
                r = 1
            end
            --put it in opponent discard
            table.insert(opponent.discard, table.remove(self.grave, r))
            self.revives = self.revives - 1
            opponent.steals = opponent.steals - 1
            print(self.name)
            print(self:stateString())
        elseif self.revives > 0 and #self.grave > 0 then
            --player can revive from grave to discard
            print(string.format("%s, Pick your revive", self.name))
            --list all in player grave
            for i = 1, #self.grave, 1 do
                print(string.format("%i: %s", i, self.grave[i]))
                --add to player choices
                self.choices[i] = self.grave[i]
            end
            --choose
            local r = tonumber(self:getPlayerInput())
            if r > #self.grave then
                r = 1
            end
            --put it in discard
            table.insert(self.discard, table.remove(self.grave, r))
            self.revives = self.revives - 1
        else
            --escape while loop if nothing in grave
            self.revives = self.revives - 1
        end
        print(self.name)
        print(self:stateString())
    end
end

--handle revives
--Input from player
--input from opponent
--output to player/s
--deprecated from text version
function playerState:handleRevives(opponent)
    while self.revives > 0 do
        self.choices = {}
        self.choiceType = "revive"
        opponent.choices = {}
        opponent.choiceType = "steal revive"
        --choose revives
        --if opponent has steal -> steal revive
        if self.revives > 0 and opponent.steals > 0 and #self.grave > 0 then
            --opponent steals from self grave
            --revive steals
            print(string.format("%s has a Steal Revive", opponent.name))
            print("Who would you like to Revive Steal?")
            --list all in player grave
            for i = 1, #self.grave, 1 do
                print(string.format("%i: %s", i, self.grave[i]))
                --add to choices
                opponent.choices[i] = self.grave[i]
            end
            --opponent choosez
            local r = tonumber(opponent:getPlayerInput())
            --put it in opponent discard
            table.insert(opponent.discard, table.remove(self.grave, r))
            self.revives = self.revives - 1
            opponent.steals = opponent.steals - 1
            print(self.name)
            print(self:stateString())
        elseif self.revives > 0 and #self.grave > 0 then
            --player can revive from grave to discard
            print(string.format("%s, Pick your revive", self.name))
            --list all in player grave
            for i = 1, #self.grave, 1 do
                print(string.format("%i: %s", i, self.grave[i]))
                --add to player choices
                self.choices[i] = self.grave[i]
            end
            --choose
            local r = tonumber(self:getPlayerInput())
            --put it in discard
            table.insert(self.discard, table.remove(self.grave, r))
            self.revives = self.revives - 1
        else
            --escape while loop if nothing in grave
            self.revives = self.revives - 1
        end
        print(self.name)
        print(self:stateString())
    end
end

--one choice at a time
--swap out or reroll
--returns true if they swapped out
function playerState:handleSwapOrReroll()
    self.choices = {}
    self.choiceType = "swap out"
    --if empty deck put discard back in
    if #self.deck == 0 then
        self:discardBackToDeck()
    end
    --if deck still empty, cancel
    if #self.deck == 0 then
        print("Nothing to swap with, take a reroll")
        self.rerolls = 1
        return false
    end

    --print options
    for i = 1, 5, 1 do
        --each dice in hand
        print(string.format("%i: Swap %s", i, self.hand[i]))
        self.choices[i] = self.hand[i]
    end
    self.choices[6] = "Reroll"
    print("6: Keep reroll")

    --if not 6 its a swap in
    local c = tonumber(self:getPlayerInput())
    if c == 6 then
        --its a reroll
        self.rerolls = 1
        return false
    else
        self.swapOut = c
        return true
    end
end

function playerState:swapIn()
    self.choices = {}
    self.choiceType = "swap in"
    --swap hand[c]
    print(string.format("Swapping %s", self.hand[self.swapOut]))
    --print whole deck
    for i = 1, #self.deck, 1 do
        --each dice in deck
        print(string.format("%i: take %s", i, self.deck[i]))
        self.choices[i] = self.deck[i]
    end
    local toTake = self:getPlayerInput()
    --remove swapped
    table.insert(self.hand, table.remove(self.deck, toTake))
    table.insert(self.deck, table.remove(self.hand, self.swapOut))
end

--handle swap choice
--Output to player/s
function playerState:handleSwap()
    print(self.name)
    print("choose to swap a dice or take a reroll")
    self:swapChoice()
    print(string.format("%s %s", self.name, self:handString()))
end

--choose whether to swap for ne in bag or keep reroll
--deprecated from text vversion
function playerState:swapChoice()
    self.choices = {}
    self.choiceType = "swap out"
    --if empty deck put discard back in
    if #self.deck == 0 then
        self:discardBackToDeck()
    end
    --if deck still empty, cancel
    if #self.deck == 0 then
        print("Nothing to swap with, take a reroll")
        self.rerolls = 1
        return
    end

    --print options
    for i = 1, 5, 1 do
        --each dice in hand
        print(string.format("%i: Swap %s", i, self.hand[i]))
        self.choices[i] = self.hand[i]
    end
    self.choices[6] = "Reroll"
    print("6: Keep reroll")

    while true do
        local c = tonumber(self:getPlayerInput())
        if c == nil then
            print("swap choice broke")
            c = 6
        end
        self.choices = {}
        self.choiceType = "swap in"
        if c > 0 and c < 6 then
            --swap hand[c]
            print(string.format("Swapping %s", self.hand[c]))
            --print whole deck
            for i = 1, #self.deck, 1 do
                --each dice in deck
                print(string.format("%i: take %s", i, self.deck[i]))
                self.choices[i] = self.deck[i]
            end
            local toTake = self:getPlayerInput()
            --remove swapped
            table.insert(self.hand, table.remove(self.deck, toTake))
            table.insert(self.deck, table.remove(self.hand, c))
            break
        elseif c == 6 then
            --keep reroll
            self.rerolls = 1
            break
        else
            --bad choice
            print("please choose from 1 to 6")
        end
    end
end

--sets outcomes
function playerState:rollHand()
    --roll for each dice
    for i = 1, 5, 1 do
        --each dice
        table.insert(self.outcomes, dice[self.hand[i]][math.random(1,6)])
    end
    return self.outcomes
end

function playerState:roll(r)
    --reroll individual dice
    self.outcomes[r] = dice[self.hand[r]][math.random(1,6)]
end

--count rerolls before reroll loop :p
function playerState:countRerolls()
    for i = 1, #self.hand, 1 do
        if self.outcomes[i] == "Reroll" then
            self.rerolls = self.rerolls + 1
        end
    end
end

--input from player
--output to the player
--deprecated from texr version
function playerState:handleRerolls()
    while self.rerolls > 0 do
        self.choices = {}
        self.choiceType = "reroll"
        print("choose which to reroll")
        print(string.format("%s, which should be rerolled?", self.name))
        for i = 1, #self.outcomes, 1 do
            print(string.format("%i: %s-%s", i, self.hand[i], self.outcomes[i]))
            self.choices[i] = self.outcomes[i]
        end
        print("6: Throw away reroll")
        self.choices[6] = "Throw away reroll"
        local r = tonumber(self:getPlayerInput())
        if r == 6 then
            --throws away the reroll
        else
            self:roll(r)
        end

        print(self.outcomes[r])

        --incase you reroll into a reroll
        if self.outcomes[r] == "Reroll" then
        else
            self.rerolls = self.rerolls - 1
        end
    end
end

--copy of handleRerolls, with an if not a while loop
--for handling one reroll at a time
function playerState:handleReroll()
    if self.rerolls > 0 then
        self.choices = {}
        self.choiceType = "reroll"
        print("choose which to reroll")
        print(string.format("%s, which should be rerolled?", self.name))
        for i = 1, #self.outcomes, 1 do
            print(string.format("%i: %s-%s", i, self.hand[i], self.outcomes[i]))
            self.choices[i] = self.outcomes[i]
        end
        print("6: Throw away reroll")
        self.choices[6] = "Throw away reroll"
        local r = tonumber(self:getPlayerInput())
        if r == 6 then
            --throws away the reroll
        else
            self:roll(r)
        end

        print(self.outcomes[r])

        --incase you reroll into a reroll
        if self.outcomes[r] == "Reroll" then
        else
            self.rerolls = self.rerolls - 1
        end
    end
end

function playerState:resetPrecalculate()
    self.attacks = 0
    self.defends = 0
    self.kills = 0
    self.revives = 0
    self.halfrev = 0
    self.targets = 0
    self.skips = 0
    self.steals = 0
    self.weakens = 0
    self.substitutes = 0
    self.occlude = 0
    self.empowers = 0
    self.atkMult = 1
    self.defMult = 1
    self.incomeMult = 1
    self.addIncome = 0
end

--calculate outcomes of dice
--[[
    each player has a number of Attacks and Defends.
    if your Attacks are larger than their Defends:
        add difference to kills
    adds tasks that needs to be done
    ]]
function playerState:calculate()
    self:resetPrecalculate()
    for i = 1, 5, 1 do
        --for each outcome
        if self.outcomes[i] == "Attack" then
            self.attacks = self.attacks + 1
        elseif self.outcomes[i] == "Defend" then
            self.defends = self.defends + 1
        elseif self.outcomes[i] == "Revive" then
            self.revives = self.revives + 1
        elseif self.outcomes[i] == "Double Atk" then
            self.attacks = self.attacks + 2
        elseif self.outcomes[i] == "Double Def" then
            self.defends = self.defends + 2
        elseif self.outcomes[i] == "Target" then
            self.targets = self.targets + 1
        elseif self.outcomes[i] == "Skip" then
            self.skips = self.skips + 1
        elseif self.outcomes[i] == "occlude" then
            self.occlude = 1
        elseif self.outcomes[i] == "Substitute" then
            self.substitutes = self.substitutes + 1
        elseif self.outcomes[i] == "Empower" then
            self.empowers = self.empowers + 1
        elseif self.outcomes[i] == "Steal Revive" then
            self.steals = self.steals + 1
        elseif self.outcomes[i] == "Weaken" then
            self.weakens = self.weakens + 2
        elseif self.outcomes[i] == "Attack and Defend" then
            self.attacks = self.attacks + 1
            self.defends = self.defends + 1
        elseif self.outcomes[i] == "Targeted Attack" then
            self.attacks = self.attacks + 1
            self.targets = self.targets + 1
        elseif self.outcomes[i] == "Add to Income" then
            self.addIncome = self.addIncome + 1
        elseif self.outcomes[i] == "Double Income" then
            self.incomeMult = self.incomeMult * 2
        elseif self.outcomes[i] == "Half Revive" then
            if self.halfrev == 1 then
                self.revives = self.revives + 1
                self.halfrev = 0
            else
                self.halfrev = 1
            end
        end
    end
end

--one at a time
function playerState:handleEmpower()
    if self.empowers > 0 then
        self.choices = {}
        self.choiceType = "empower"
        --ask player
        print(string.format("%s has an Empower. Choose to Double total", self.name))
        print("1: Attacks")
        print("2: Defends")
        self.choices[1] = "Attacks"
        self.choices[2] = "Defends"
        --get choice
        local c = tonumber(self:getPlayerInput())
        --multiply choice
        if c == 1 then
            self.atkMult = self.atkMult * 2
            self.empowers = self.empowers - 1
        elseif c == 2 then
            self.defMult = self.defMult * 2
            self.empowers = self.empowers - 1
        else
            print("Choice out of range")
        end
    end
end

--input from player
--output to player/s
--deprecated from text version
function playerState:handleEmpowers()
    while self.empowers > 0 do
        self.choices = {}
        self.choiceType = "empower"
        --ask player
        print(string.format("%s has an Empower. Choose to Double total", self.name))
        print("1: Attacks")
        print("2: Defends")
        self.choices[1] = "Attacks"
        self.choices[2] = "Defends"
        --get choice
        local c = tonumber(self:getPlayerInput())
        --multiply choice
        if c == 1 then
            self.atkMult = self.atkMult * 2
            self.empowers = self.empowers - 1
        elseif c == 2 then
            self.defMult = self.defMult * 2
            self.empowers = self.empowers - 1
        else
            print("Choice out of range")
        end
    end
end

--handle skips
--input from player
--output to player/s
--deprecated from text version
function playerState:handleSkips()
    while self.skips > 0 and #self.hand > 0 do
        self.choices = {}
        self.choiceType = "skip"
        --self puts 1 from hand into deck
        print(string.format("%s Pick who goes back into deck", self.name))
        for i = 1, #self.hand, 1 do
            print(string.format("%i: %s", i, self.hand[i]))
            self.choices[i] = self.hand
        end
        local s = tonumber(self:getPlayerInput())
        if s > #self.hand then
            --TODO clean this up, failsafe rn
            table.insert(self.deck, table.remove(self.hand, 1))
        else
            table.insert(self.deck, table.remove(self.hand, s))
        end
        self.skips = self.skips - 1
    end
end

--one at a time skip for playerr input
function playerState:handleSkip()
    if self.skips > 0 and #self.hand > 0 then
        self.choices = {}
        self.choiceType = "skip"
        --self puts 1 from hand into deck
        print(string.format("%s Pick who goes back into deck", self.name))
        for i = 1, #self.hand, 1 do
            print(string.format("%i: %s", i, self.hand[i]))
            self.choices[i] = self.hand
        end
        local s = tonumber(self:getPlayerInput())
        if s > #self.hand then
            --TODO clean this up, failsafe rn
            table.insert(self.deck, table.remove(self.hand, 1))
        else
            table.insert(self.deck, table.remove(self.hand, s))
        end
        self.skips = self.skips - 1
    end
end

--handle kills
    --[[
    for each kill
        roll a d6,
        if target -> player chooses, unless occlude
        if it lands on 1-5 -> hit that spot
        if repeat -> miss
        if hit safe -> miss
        if substitute -> one miss
    ]]
--input from player
--output to player/s
--deprecated from text version
function playerState:handleKills(opponent)
    while self.kills > 0 do
        self.choices = {}
        self.choiceType = "target"
        if self.targets > 0 and opponent.occlude < 1 then
            --targeted kills
            print(string.format("%s, pick your kill", self.name))
            for i = 1, #opponent.hand, 1 do
                print(string.format("%i: Kill %s", i, opponent.hand[i]))
                self.choices[i] = opponent.hand[i]
            end
            local k = tonumber(self:getPlayerInput())
            if opponent.outcomes[k] == "Safe" then
                -- they avoid the hit
                print(string.format("%s's %s was Safe", opponent.name, opponent.hand[k]))
            else
                opponent:sendToGrave(k)
            end
            self.targets = self.targets - 1
            self.kills = self.kills - 1
        else
            --random kills
            if opponent.occlude > 0 then
                print(string.format("%s has occlude", opponent.name))
            end
            print("Rolling for kills")
            local r = math.random(1,6)
            if opponent.outcomes[r] == "Safe" then
                -- they avoid the hit
                print(string.format("%s's %s was Safe", opponent.name, opponent.hand[r]))
            else
                opponent:sendToGrave(r)
            end
            self.kills = self.kills - 1
        end
    end
end

--one at a time for targets and gui
function playerState:handleKill(opponent)
    local s = ""
    if self.kills > 0 then
        self.choices = {}
        self.choiceType = "target"
        if self.targets > 0 and opponent.occlude < 1 then
            --targeted kills
            print(string.format("%s, pick your kill", self.name))
            for i = 1, #opponent.hand, 1 do
                print(string.format("%i: Kill %s", i, opponent.hand[i]))
                self.choices[i] = opponent.hand[i]
                s = string.format("%s's %s was Target Killed\n", opponent.name, opponent.hand[i]) .. s
            end
            local k = tonumber(self:getPlayerInput())
            if opponent.outcomes[k] == "Safe" then
                -- they avoid the hit
                print(string.format("%s's %s was Safe", opponent.name, opponent.hand[k]))
                s = string.format("%s's %s was Safe", opponent.name, opponent.hand[k]) .. s
            else
                s = opponent:sendToGrave(k)
            end
            self.targets = self.targets - 1
            self.kills = self.kills - 1
        else
            --random kills
            if opponent.occlude > 0 then
                print(string.format("%s has occlude", opponent.name))
            end
            print("Rolling for kills")
            local r = math.random(1,6)
            if opponent.outcomes[r] == "Safe" then
                -- they avoid the hit
                print(string.format("%s's %s was Safe", opponent.name, opponent.hand[r]))
                s = string.format("%s's %s was Safe ", opponent.name, opponent.hand[r]) .. s
            else
                s = opponent:sendToGrave(r)
            end
            self.kills = self.kills - 1
        end
    end
    return s
end

function playerState:measureKills(opponent)
    --raise to 0 to avoid negative kills
    self.kills = math.max((self.attacks * self.atkMult) - math.max((opponent.defends * opponent.defMult) - self.weakens, 0),0)

    --if enemy has a occlude, set targets to 0
    if opponent.occlude > 0 then
        self.targets = 0
    end
end

function playerState:outcomeString()
    return string.format("outcomes: 1:%s, 2:%s, 3:%s, 4:%s, 5:%s", 
        self.outcomes[1], self.outcomes[2], self.outcomes[3], self.outcomes[4], self.outcomes[5])
end

function playerState:handString()
    return string.format("has 1:%s, 2:%s, 3:%s, 4:%s, 5:%s", 
        self.hand[1], self.hand[2], self.hand[3], self.hand[4], self.hand[5])
end

function playerState:getLife()
    return #self.deck + #self.discard + #self.hand
end

--called after hand is discarded only
function playerState:isAlive()
    local total = #self.deck + #self.discard
    if total < 5 then
        return false
    end
    return true
end

--print current game state
--incl deck, grave, hand
function playerState:stateString()
    local s = "Deck: "
    --print whole deck
    for i = 1, #self.deck, 1 do
        --each dice in deck
        s = s .. self.deck[i] .. "; "
    end
    s = s .. "\nDiscard: "
    for i = 1, #self.discard, 1 do
        --each dice in discard
        s = s .. self.discard[i] .. "; "
    end
    s = s .. "\nGrave: "
    for i = 1, #self.grave, 1 do
        --each dice in grave
        s = s .. self.grave[i] .. "; "
    end
    s = s .. "\nWallet: " .. self.wallet .. "; Life: " .. self:getLife()
    return s
end