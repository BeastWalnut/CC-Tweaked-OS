---------------Dependencies---------------
local helpers = require 'beast.api'
local tpoint = helpers.tpoint

----------------"Globals"-----------------
local BUTTON_PADDING = 4
local X_SPACING = 9

------------------------------------------
-- Functions
------------------------------------------
local function exit(menus)
	menus.current = 'shell'
end

local function draw(str, menu, width, height)
	menu:draw()

	local header = string.pad(str, width, '=')
	local separator = string.pad('', width, '=')

	term.setBackgroundColor(colors.black)
	helpers.print(header, {
		color = colors.yellow,
		x = 1,
		y = 1
	})

	helpers.write(separator, {
		color = colors.yellow,
		x = 1,
		y = height - 3
	})
end

local function run(str, menuName, menus, width, height)
	local menu = menus[menuName](menus, width, height)
	menus.current = menuName

	local header = string.format(' %s ', str)
	draw(header, menu, width, height)

	while menus.current == menuName do
		local event = { menu:handleEvents() }
		if event[1] == 'button_click' then
			local clicked = event[2]
			menu.buttonList[clicked].func(menus)

			draw(header, menu, width, height)
		elseif event[1] == 'term_resize' then
			width, height = helpers.getSize(24, 15)
			menu = menus[menuName](menus, width, height)

			draw(header, menu, width, height)
		end
	end
end

local function main(menus, touchp, width, height)
	local half = (width / 2) + 1

	local settingsStr = 'Settings'
	local settingsX = (half - (#settingsStr + BUTTON_PADDING)) / 2

	local exitStr = 'Exit'
	local exitX = half + (half - (#exitStr + BUTTON_PADDING)) / 2

	if width > X_SPACING + (#settingsStr + #exitStr) + (BUTTON_PADDING * 2) then
		local halfExtra = X_SPACING / 2
		settingsX = half - halfExtra - (#settingsStr + BUTTON_PADDING)
		exitX = half + halfExtra
	end

	tpoint.add(touchp, settingsStr,
		function() run('Settings', 'settings', menus, width, height) end,

		settingsX + 1, height - 2,
		#settingsStr + BUTTON_PADDING, 3,

		colors.purple
	)

	tpoint.add(touchp, exitStr,
		exit,

		exitX, height - 2,
		#exitStr + BUTTON_PADDING, 3,

		colors.red
	)
end

local function back(parent, touchp, width, height)
	local backStr = 'Back'
	local backX = (width - (#backStr + BUTTON_PADDING)) / 2

	tpoint.add(touchp, backStr,
		function(menus) menus.current = parent end,

		backX + 1, height - 2,
		#backStr + BUTTON_PADDING, 3,

		colors.brown
	)
end

------------------------------------------
return {
	main = main,
	back = back,
	run = run
}
