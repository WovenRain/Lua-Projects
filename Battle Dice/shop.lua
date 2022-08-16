shop = {}

cost = {1,2,4,8,16}

function shop:build()
    math.randomseed(os.time())
    --fill shop and init
    self.firstPick = nil
    self.lastPick = nil
    self.firstGone = false
    self.allGone = false

    --the run of 5 that you can buy for cost[x]
    self.run = {}

    --the deck full of things to buy
    --two of each
    self.deck = {
        "Merchant", "Merchant",
        "Banker", "Banker",
        "Assassin", "Assassin",
        "Spy", "Spy",
        "Squire", "Squire",
        "Tank", "Tank",
        "Knight", "Knight",
        "Necromancer", "Necromancer",
        "Mage", "Mage",
        "Sorcerer", "Sorcerer",
        "Archer", "Archer",
        "Bard", "Bard",
        --"Cleric", "Cleric",
        --"Fighter", "Fighter",
        --"Rogue", "Rogue",
        --"Wizard", "Wizard",--]]
    }
    --fill the shop
    self:fillRun()
end

function shop:fillRun()
    while #self.run < 5 and #self.deck > 0 do
        --take randomly from deck into run
        table.insert(self.run, table.remove(self.deck, math.random(1, #self.deck)))
    end
end

function shop:pickFirst(p1, p2)
    --set self.firstPick
    if p1.kills > p2.kills then
        --p2 chooses first
        self.firstPick = p2
    elseif p2.kills > p1.kills then
        --p1 chooses first
        self.firstPick = p1
    else
        --must be equal
        if self.lastPick == nil or self.lastPick == p2 then
            --p1
            self.firstPick = p1
        else
            --p2
            self.firstPick = p2
        end
    end
    --keep track for next round
    self.lastPick = self.firstPick
    --new shopping round
    self.firstGone = false
    self.allGone = false
end

--output to players
function shop:showShop(p)
    print("-------SHOP-------")
    p.choices = {}
    p.choiceType = "shop"
    for i = 1, #self.run, 1 do
        print(string.format("%i: %s for %i Coins", i, self.run[i], cost[i]))
        p.choices[i] = self.run[i]
    end
    p.choices[6] = "Dont buy"
    print("6: Don't buy")
end

--one at a time
function shop:handleShop(p1, p2)
    if self.firstGone == false then
        --first pick hasnt gone yet
        if p1 == self.firstPick then
            --p1 goes first
            print(string.format("%s gets first pick", p1.name))
            shop:showShop(p1)
            shop:allowBuy(p1)
        else
            --p2 picks first, then p1
            shop:showShop(p2)
            shop:allowBuy(p2)
        end
        self.firstGone = true
    else
        --second round of shop
        if p2 == self.firstPick then
            --p1 goes second
            print(string.format("%s gets first pick", p1.name))
            shop:showShop(p1)
            shop:allowBuy(p1)
        else
            --p2 goes second
            shop:showShop(p2)
            shop:allowBuy(p2)
        end
        --now both have gone
        self.allGone = true
    end
end

--handles players buying from the shop
--input from player/s
--output to players
function shop:handleShopping(p1, p2)
    if p1 == shop.firstPick and self.firstGone == false then
        --p1 picks first, then p2
        print(string.format("%s gets first pick", p1.name))
        shop:showShop(p1)
        shop:allowBuy(p1)
        shop:showShop(p2)
        shop:allowBuy(p2)
    else
        --p2 picks first, then p1
        print(string.format("%s gets first pick", p2.name))
        shop:showShop(p2)
        shop:allowBuy(p2)
        shop:showShop(p1)
        shop:allowBuy(p1)
    end
end

--input from player/s
--output to player/s
function shop:allowBuy(p)
    while #self.run > 0 do
        print(string.format("%s has %i coins", p.name, p.wallet))
        local b = tonumber(p:getPlayerInput())
        if b == 6 then
            --they dont buy
            print(string.format("%s left the shop", p.name))
            break
        elseif p.wallet < cost[b] then
            --cannot afford
            print(string.format("%s couldn't afford that. Try again", p.name))
        else
            shop:buy(p,b)
            break
        end
    end
    shop:fillRun()
end

function shop:buy(player, place)
    --add self.run[place] to player.deck and pop
    print(string.format("%s bought the %s for %i coin", player.name, shop.run[place], cost[place]))
    player.wallet = player.wallet - cost[place]
    table.insert(player.deck, table.remove(shop.run, place))
end

function shop:isOpen()
    if #self.run == 0 then
        return false
    end
    return true
end