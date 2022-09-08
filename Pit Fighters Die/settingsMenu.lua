settingsMenu = {}
require("Buttons")
require("BasicMenu")

local buttons = {}

function settingsMenu:load()
    table.insert(buttons, newButton(
		"Main Menu",
		function()
			changeGametype(0)
		end
	))
	for i in ipairs(buttons) do
		buttons[i].now = true
	end
end

function settingsMenu:draw()
    BasicMenu.draw("Game by\nWovenRain\nMusic by\nPatrick De Arteaga", buttons)
end