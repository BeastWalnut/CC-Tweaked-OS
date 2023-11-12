-- Dependencies.
local touchpoint = require 'beast.touchpoint'
local helpers = require 'beast.api'
local tpoint = helpers.tpoint
local menu = require 'beast.menu'

local oldPull = os.pullEvent
os.pullEvent = os.pullEventRaw

-- "Globals"
local BUTTON_PADDING = 4
local Y_SPACING = 3
local X_SPACING = 4

-- Functions
local menus = {}

function menus:main(width, height)
	local main = touchpoint.new()
	menu.main(self, main, width, height)

	local nicksStr = 'Nicks'
	local nicksX = (width - (#nicksStr + BUTTON_PADDING)) / 2

	tpoint.add(main, nicksStr,
		nil, --function() menu.run('nicks', 'Nickname', self) end,

		nicksX + 1, Y_SPACING,
		#nicksStr + BUTTON_PADDING, 3,

		colors.cyan
	)

	return main
end

function menus:settings(width, height)
	local settings = touchpoint.new()
	menu.back('main', settings, width, height)

	local userStr = 'Change User'
	local userX = (width - (#userStr + BUTTON_PADDING + 2)) / 2

	local lastX, lastY = tpoint.add(settings, userStr,
		nil,

		userX + 1, Y_SPACING,
		#userStr + BUTTON_PADDING + 2, 3,

		colors.lightGray
	)
	return settings
end

-- Run program.
menu.run('Walnut-OS', 'main', menus, helpers.getSize(24, 15))

-- Exit progrm.
term.setCursorPos(1, 2)
os.pullEvent = oldPull
