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
outcomes = {}
outcomes[1] = {"Attack","Roll to kill an Enemy"}
outcomes[2] = {"Defend","Block an Attack"}
outcomes[3] = {"Revive","Take one dice from you grave, \nput it in your discards"}
outcomes[4] = {"Reroll","Reroll a dice"}
outcomes[5] = {"Target","Turn your first kill roll \ninto a choice"}
outcomes[6] = {"Half Revive","Get 2 to revive"}
outcomes[7] = {"Skip","Pick one survivor after battle \nto go directly into your deck"}
outcomes[8] = {"Weaken","Cancel 2 enemy defends"}
outcomes[9] = {"Double Income","Double this rounds income"}
outcomes[10] = {"Add to Income","Add 1 to this rounds income"}
outcomes[11] = {"Empower","Double either attacks or defends"}
outcomes[12] = {"Occlude","Enemy cannot Target"}
outcomes[13] = {"Steal Revive","If enemy has a revive, instead \nRevive from their grave"}
outcomes[14] = {"Safe","This dice cannot die"}
outcomes[15] = {"Substitute","First enemy kill is saved \nand put directly in deck"}
