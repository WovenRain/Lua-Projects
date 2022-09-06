ChooseAI = {}
require("Buttons")
require("BasicMenu")

local buttons = {}

function ChooseAI.load()
	table.insert(buttons, newButton(
		"Plays_1",
		function()
			changeGametype(1)
		end
	))

	table.insert(buttons, newButton(
		"The Fool",
		function()
			changeGametype(2)
		end
	))

	table.insert(buttons, newButton(
		"Emporer",
		function()
			changeGametype(3)
		end
	))

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

function ChooseAI.update(dt)
end

function ChooseAI.draw()
	BasicMenu.draw(buttons)
end
