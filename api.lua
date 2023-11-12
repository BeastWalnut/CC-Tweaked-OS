---------------Dependencies---------------
local completion = require 'cc.completion'
local pretty = require 'cc.pretty'
local expectObj = require 'cc.expect'
local expect, field = expectObj.expect, expectObj.field

-------------------
-- Table Functions.
-------------------

function table.contains(tbl, value)
	for _, element in pairs(tbl) do
		if value == element then return true end
	end

	return false
end

function table.clone(tbl)
	local result = {}

	for key, item in pairs(tbl) do result[key] = item end

	return result
end

function table.merge(...)
	local tables = { ... }

	if #tables == 1 then return tables[1] end

	for key, table in ipairs(tables) do
		assert(type(table) == 'table', string.format('Expected a table as function parameter %d', key))
	end

	local table1 = table.clone(tables[1])
	local table2 = table.merge(table.unpack(tables, 2))

	for key, item in pairs(table2) do table1[key] = table1[key] or item end

	return table1
end

--------------------
-- String Functions.
--------------------

function string.pad(str, length, c)
	if #str >= length then
		return str
	end

	local char = c or " "
	local rep = (length - #str) / 2

	return string.rep(char, math.ceil(rep)) .. str .. string.rep(char, math.floor(rep))
end

-------------------
-- Better terminal.
-------------------

local function getSize(width, height)
	local w, h = term.getSize()

	if w < (width or 1) then
		local errorText = string.format('Screen is too small. Expected %d width, got %d.', width, w)
		error(errorText, 0)
	elseif h < (height or 1) then
		local errorText = string.format('Screen is too small. Expected %d height, got %d.', height, h)
		error(errorText, 0)
	end

	return w, h
end

local function print(text, configs)
	expect(1, text, 'string')

	local color = term.getTextColor()

	if configs then
		local curX, curY = term.getCursorPos()

		local x = configs.x or curX
		local y = configs.y or curY

		if configs.centerX and configs.centerX > #text then
			local padding = (configs.centerX - #text) / 2
			x = x + padding
		elseif configs.right then
			x = (configs.right - #text) + 1
		end

		term.setCursorPos(x or curX, y or curY)
		color = configs.color or color
	end

	local prettyText = pretty.text(text, color)
	pretty.print(prettyText)
end

local function write(text, configs)
	expect(1, text, 'string')

	local color = term.getTextColor()

	if configs then
		local curX, curY = term.getCursorPos()

		local x = configs.x or curX
		local y = configs.y or curY

		if configs.centerX and configs.centerX > #text then
			local padding = (configs.centerX - #text) / 2
			x = x + padding
		elseif configs.right then
			x = (configs.right - #text) + 1
		end

		term.setCursorPos(x or curX, y or curY)
		color = configs.color or color
	end

	local prettyText = pretty.text(text, color)
	pretty.write(prettyText)
end

--------------
-- User input.
--------------
local input = {}

function input.completor(answers, modifier, func)
	return function(text)
		local results = table.clone(answers)

		if string[modifier] then
			for key, ans in ipairs(answers) do
				local modifiedAnsw = modifier(ans)
				table.insert(results, #results + 1, modifiedAnsw)
			end
		end

		if func then results = table.merge(func(), results) end

		return completion.choice(text, results or {})
	end
end

function input.readSmart(color, completer, history, replace, default)
	local current = term.current()
	current.setTextColor(color)
	current.write('>')

	local answer = read(replace, history, completer, default)
	print('')

	return answer
end

---------------------
-- File Interactions.
---------------------
local files = {}

-- Read the raw file.
function files.read(fileName)
	local file = fs.open(fileName, 'r')
	local string = file.readAll()
	file.close()

	return string
end

-- Write a raw string into a file.
function files.write(file, string)
	local file = fs.open(file, 'w')
	file.write(string)
	file.close()
end

-- Append a raw string into a file
function files.append(file, string)
	local file = fs.open(file, 'a')
	file.write(string)
	file.close()
end

-- Read data from a file.
function files.readData(fileName)
	local file = fs.open(fileName, 'r')
	local data = textutils.unserialize(file.readAll())
	file.close()

	return data
end

-- Write data to a file.
function files.writeData(file, data)
	local file = fs.open(file, 'w')
	file.write(textutils.serialize(data))
	file.close()
end

------------------------
-- Touchpoint functions.
------------------------
local tpoint = {}

function tpoint.add(touchp, text, func, x, y, width, height, inactiveColor, activeColor, inactiveText, activeText)
	local xEnd = math.ceil(x + width) - 1
	local yEnd = math.ceil(y + height) - 1
	func = func or function() end

	touchp:add(
		text, func,

		math.ceil(x), math.ceil(y),
		xEnd, yEnd,

		inactiveColor, activeColor,
		inactiveText, activeText
	)

	return xEnd, yEnd
end

function tpoint.textbox(touchp, name, width)
	touchp.rename(name, '>')
	local str = ''

	while true do
		local event, key = os.pullEvent('key')
		if event == 'key' then
			if key == keys.enter then
				touchp.rename('>' .. str, name)
				return str
			elseif key == keys.backspace then
				str = string.sub(str, 1, -2)
			end
		end
		os.startTimer(1)

		event, key = os.pullEvent('char')
		if event == 'char' and #str < width then
			local newStr = str .. key
			touchp.rename('>' .. str, '>' .. newStr)

			str = newStr
		end
	end
end

------------------------

return {
	getSize = getSize,
	print = print,
	write = write,
	input = input,
	files = files,
	tpoint = tpoint
}
