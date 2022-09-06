BasicAI = {}

--[[
    ChoiceTypes

    swap out
        LeastPreferred

    swap in
        Preferred
        or something smarter if double compliment

    revive
        Preferred

    steal revive
        Preferred

    reroll
        reroll empties: "-"
        or out of a revive if enemy has steals

    empower
        Attacks, Defends

    skip
        Preferred

    target
        MostHated

    shop
        Preferred 
        first within wallet reach

    Choices
    Capitalised outcomes and dicetypes
]]
--
Preferred = {
    "Squire",
    "Mage",
    "Bard",
    "Necromancer",
    "Cleric",
    "Spy",
    "Archer",
    "Sorcerer",
    "Knight",
    "Assassin",
    "Tank",
    "Banker",
    "Merchant",
    "Wizard",
    "Rogue",
    "Fighter"
}

--assume Preferred are best
MostHated = Preferred

function BasicAI:getChoice(player)
    self.PlayerS = player
    if player.choiceType == "swap out" then
        return 6
    elseif player.choiceType == "swap in" then
        return BasicAI:FirstUp()
    elseif player.choiceType == "revive" then
        return BasicAI:FirstUp()
    elseif player.choiceType == "steal revive" then
        return BasicAI:FirstUp()
    elseif player.choiceType == "reroll" then
        return BasicAI:FindEmpty()
    elseif player.choiceType == "empower" then
        --About as simple as it can be, if no attacks: double defends
        if self.PlayerS.attacks == 0 then
            return 2
        else
            return 1
        end
    elseif player.choiceType == "skip" then
        return BasicAI:FirstUp()
    elseif player.choiceType == "target" then
        return BasicAI:FirstUp()
    elseif player.choiceType == "shop" then
        --return 1
        BasicAI:RemoveTooExpensive()
        return BasicAI:FirstUp()
    end
    print("BasicAI broke")
    return 1
end

function BasicAI:FindEmpty()
    for i = 1, #self.PlayerS.choices, 1 do 
        print(self.PlayerS.choices[i])
        if self.PlayerS.choices[i] == "-" then
            return i
        end
    end
    for i = 1, #self.PlayerS.choices, 1 do 
        if self.PlayerS.choices[i] == "Reroll" then
            return i
        end
    end
    return 6
end

function BasicAI:RemoveTooExpensive()
    local cost = {1,2,4,8,16}
    local c = 2
    for i = #cost, 1, -1 do
        if self.PlayerS.wallet < cost[i] then
            --print("c = "..i)
            c = i
        end
    end

    for i = 1, #self.PlayerS.choices, 1 do
        table.remove(self.PlayerS.choices, c)
    end
end

function BasicAI:FirstUp()
    for i = 1, #Preferred, 1 do
        for j = 1, #self.PlayerS.choices, 1 do
            --if the highest Preferred is in choice
            if Preferred[i] == self.PlayerS.choices[j] then
                --take that choice
                print("Taking " .. self.PlayerS.choices[j])
                return j
            end
        end
    end
    --if somehow this fails
    print("Failure in BasicAI")
    return 1
end