Menu = {}
require("Buttons")
require("BasicMenu")

local buttons = {}

function Menu.load()
	BasicMenu.load()
	
	--TODO bringup AI menu
	table.insert(buttons, newButton(
		"Play vs AI",
		function()
			changeGametype(-1)
		end
	))

	table.insert(buttons, newButton(
		"Settings",
		function()
			changeGametype(-2)
		end
	))

	table.insert(buttons, newButton(
		"Quit",
		function()
			love.event.quit(0)
		end
	))

end

function Menu.update(dt)
end

function Menu.draw()
	BasicMenu.draw("Pit Fighters Die\nPrecursor",buttons)
end
