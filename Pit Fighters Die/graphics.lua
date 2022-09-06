--instantiate all the images
graphics = {}

--draw the images where they need to be scaled to the resolution

-- plane = love.graphics.newImage("plane.png")

--[[
    Graphics
BoxX is the window width / 20
if boxX is 64, width is 1280 -> BoxX is scaled 
64/1280 - 1
32/640 - 0.5
6.4/128 - 0.1

so  resolution/1280
ie  640/1280 = 0.5
    128/1280 = 0.1

dice plates are 128     (*2)
player plates are 1024  (*16)
]]
function graphics:load()
    --1280 is 64*20, 64*64 is the icon size
    --scale will always be by this, 
    --some will hand over .5 to make them extra small
    self.scaleW = love.graphics.getWidth()/1280

    --Attack
    self.attack = love.graphics.newImage("/graphics/outcomes/attack.png")
    
    --Double Atk
    self.doubleAtk = love.graphics.newImage("/graphics/outcomes/doubleAtk.png")

    --Defend
    self.defend = love.graphics.newImage("/graphics/outcomes/defend.png")

    --Double Def
    self.doubleDef = love.graphics.newImage("/graphics/outcomes/doubleDef.png")
    
    --Revive
    self.revive = love.graphics.newImage("/graphics/outcomes/revive.png")
    
    --Target
    self.target = love.graphics.newImage("/graphics/outcomes/target.png")
    
    --Skip
    self.skip = love.graphics.newImage("/graphics/outcomes/skip.png")
    
    --Reroll
    self.reroll = love.graphics.newImage("/graphics/outcomes/reroll.png")
    
    --Half Revive
    self.halfRevive = love.graphics.newImage("/graphics/outcomes/halfRevive.png")
    
    --Weaken
    self.weaken = love.graphics.newImage("/graphics/outcomes/weaken.png")
    
    --Double Income
    self.doubleIncome = love.graphics.newImage("/graphics/outcomes/doubleIncome.png")
    
    --Add to Income
    self.addToIncome = love.graphics.newImage("/graphics/outcomes/addToIncome.png")
    
    --Empower
    self.empower = love.graphics.newImage("/graphics/outcomes/empower.png")
    
    --Occlude
    self.occlude = love.graphics.newImage("/graphics/outcomes/occlude.png")
    
    --Safe
    self.safe = love.graphics.newImage("/graphics/outcomes/safe.png")
    
    --Substitute
    self.substitute = love.graphics.newImage("/graphics/outcomes/substitute.png")
    
    --Steal Revive
    self.stealRevive = love.graphics.newImage("/graphics/outcomes/stealRevive.png")
    
    --Attack and Defend
    self.attackAndDefend = love.graphics.newImage("/graphics/outcomes/attackAndDefend.png")
    
    --Targeted Attack
    self.targetedAttack = love.graphics.newImage("/graphics/outcomes/targetedAttack.png")

    --Dice plates
    --Fighter
    self.fighter = love.graphics.newImage("/graphics/dice/fighter.png")

    --Rogue
    self.rogue = love.graphics.newImage("/graphics/dice/rogue.png")

    --Cleric
    self.cleric = love.graphics.newImage("/graphics/dice/cleric.png")

    --Wizard
    self.wizard = love.graphics.newImage("/graphics/dice/wizard.png")

    --Merchant
    self.merchant = love.graphics.newImage("/graphics/dice/merchant.png")

    --Banker
    self.banker = love.graphics.newImage("/graphics/dice/banker.png")

    --Assassin
    self.assassin = love.graphics.newImage("/graphics/dice/assassin.png")

    --Spy
    self.spy = love.graphics.newImage("/graphics/dice/spy.png")

    --Squire
    self.squire = love.graphics.newImage("/graphics/dice/squire.png")

    --Tank
    self.tank = love.graphics.newImage("/graphics/dice/tank.png")

    --Knight
    self.knight = love.graphics.newImage("/graphics/dice/knight.png")

    --Necromancer
    self.necromancer = love.graphics.newImage("/graphics/dice/necromancer.png")

    --Mage
    self.mage = love.graphics.newImage("/graphics/dice/mage.png")

    --Sorcerer
    self.sorcerer = love.graphics.newImage("/graphics/dice/sorcerer.png")

    --Archer
    self.archer = love.graphics.newImage("/graphics/dice/archer.png")

    --Bard
    self.bard = love.graphics.newImage("/graphics/dice/bard.png")
    
    --Player Plates 1024*1024
    --soldierA
    self.soldierA = love.graphics.newImage("/graphics/players/soldierA.png")

    --soldierB
    self.soldierB = love.graphics.newImage("/graphics/players/soldierB.png")

    --mageA
    self.mageA = love.graphics.newImage("/graphics/players/mageA.png")

    --mageB
    self.mageB = love.graphics.newImage("/graphics/players/mageB.png")
    
    --mageC
    self.mageC = love.graphics.newImage("/graphics/players/mageC.png")

    --edgy
    self.edgy = love.graphics.newImage("/graphics/players/edgy.png")

    --fool
    self.fool = love.graphics.newImage("/graphics/players/fool.png")

    --plays_1
    self.plays_1 = love.graphics.newImage("/graphics/players/plays_1.png")

    --spider
    self.spider = love.graphics.newImage("/graphics/players/spider.png")
end

function graphics:update(dt)
    --make sure we're still scaled right once a frame
    --maybe idk
    --self.scale = love.graphics.getWidth()/1280
end

function graphics:printPlayer(player, x, y, scale)
    --going to be boxX*4
    scale = scale/4
    if player == "soldierA" then
        love.graphics.draw(self.soldierA, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif player == "soldierB" then
        love.graphics.draw(self.soldierB, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif player == "mageA" then
        love.graphics.draw(self.mageA, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif player == "mageB" then
        love.graphics.draw(self.mageB, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif player == "mageC" then
        love.graphics.draw(self.mageC, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif player == "edgy" then
        love.graphics.draw(self.edgy, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif player == "fool" then
        love.graphics.draw(self.fool, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif player == "plays_1" then
        love.graphics.draw(self.plays_1, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif player == "spider" then
        love.graphics.draw(self.spider, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    end
end

--directs from string to function
--draw function for each outcome 
--love.graphics.draw(plane, 200, 200, 0, 0.5, 0.5) -- 0 is for rotation, see the wiki
function graphics:printOutcome(outcome, x, y, scale)
    --switch on outcome string
    if outcome == "Attack" then
        love.graphics.draw(self.attack, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Double Atk" then
        love.graphics.draw(self.doubleAtk, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Defend" then
        love.graphics.draw(self.defend, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Double Def" then
        love.graphics.draw(self.doubleDef, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Revive" then
        love.graphics.draw(self.revive, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Target" then
        love.graphics.draw(self.target, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Skip" then
        love.graphics.draw(self.skip, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Reroll" then
        love.graphics.draw(self.reroll, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Half Revive" then
        love.graphics.draw(self.halfRevive, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Weaken" then
        love.graphics.draw(self.weaken, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Double Income" then
        love.graphics.draw(self.doubleIncome, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Add to Income" then
        love.graphics.draw(self.addToIncome, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Empower" then
        love.graphics.draw(self.empower, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Occlude" then
        love.graphics.draw(self.occlude, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Safe" then
        love.graphics.draw(self.safe, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Substitute" then
        love.graphics.draw(self.substitute, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Steal Revive" then
        love.graphics.draw(self.stealRevive, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Attack and Defend" then
        love.graphics.draw(self.attackAndDefend, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif outcome == "Targeted Attack" then
        love.graphics.draw(self.targetedAttack, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    end
end

--function to draw relevant dice plate
function graphics:printDicePlate(dice, x, y, scale)
    --not too sure about this, looks ok I guess :/ 
    --may have to continue to play around with GUI now I've got decent plates
    scale = scale/4
    if dice == "Fighter" then
        love.graphics.draw(self.fighter, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Rogue" then
        love.graphics.draw(self.rogue, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Cleric" then
        love.graphics.draw(self.cleric, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Wizard" then
        love.graphics.draw(self.wizard, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Merchant" then
        love.graphics.draw(self.merchant, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Banker" then
        love.graphics.draw(self.banker, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Assassin" then
        love.graphics.draw(self.assassin, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Spy" then
        love.graphics.draw(self.spy, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Squire" then
        love.graphics.draw(self.squire, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Tank" then
        love.graphics.draw(self.tank, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Knight" then
        love.graphics.draw(self.knight, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Necromancer" then
        love.graphics.draw(self.necromancer, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Mage" then
        love.graphics.draw(self.mage, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Sorcerer" then
        love.graphics.draw(self.sorcerer, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Archer" then
        love.graphics.draw(self.archer, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    elseif dice == "Bard" then
        love.graphics.draw(self.bard, x, y, 0, scale*self.scaleW, scale*self.scaleW)
    end
end