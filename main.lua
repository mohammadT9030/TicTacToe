---@diagnostic disable: undefined-global, need-check-nil
-- Coded by Eryk 'RootKiller' Dwornicki
-- Public domain licence.

require "AI"

local currentRoundTime = 0

local playgroundSize = 0

local SHAPE_UNSET = 0
local SHAPE_CROSS = 1
local SHAPE_CIRCLE = 2

local playerWonTimer = nil
local playerWonShape = SHAPE_UNSET
local matchDraw = false

local grid = {
	SHAPE_UNSET, SHAPE_UNSET, SHAPE_UNSET,
	SHAPE_UNSET, SHAPE_UNSET, SHAPE_UNSET,
	SHAPE_UNSET, SHAPE_UNSET, SHAPE_UNSET
}

local cellsInRow = 3
local diagonalCellsCount = 3

local rows = #grid / cellsInRow
local cols = cellsInRow


local ROUND_TIME = 10.0 * rows * cols

local occupiedCells = 0

local playgroundPos = nil

function cellIdToXY(cellid)
	if not cellid then
		return nil
	end

	return { x = 1 + math.ceil((cellid - 1) % cols), y = math.ceil(cellid / cols) }
end

function drawShape(shape, dx, dy, dw, dh, detail)
	if shape == SHAPE_CROSS then
		love.graphics.line(dx, dy, dx + dw, dy + dh)
		love.graphics.line(dx + dw, dy, dx, dy + dh)
	elseif shape == SHAPE_CIRCLE then
		love.graphics.circle("line", dx + dw * 0.5, dy + dh * 0.5, ((dw+dh) / 2) * 0.5, detail)
	end
end

function isPointInsideRect(rx, ry, rw, rh, px, py)
	if not (rx and ry and rw and rh and px and py) then
		return false
	end

	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

function getCellIdFromXY(x, y)
	return 1 + (x - 1) + cols * (y - 1)
end

function getCellIdFromPoint(px, py)
	if not playgroundPos then
		return nil
	end

	if not isPointInsideRect(playgroundPos.x, playgroundPos.y, playgroundSize, playgroundSize, px, py) then
		return nil
	end

	local relX = px - playgroundPos.x
	local relY = py - playgroundPos.y

	local x = math.floor(relX / cellSize) + 1
	local y = math.floor(relY / cellSize) + 1
	if not isValidCellXY(x, y) then
		return nil
	end

	return getCellIdFromXY(x, y)
end

local currentPlayerShape = SHAPE_CROSS

function switchPlayer()
	if currentPlayerShape == SHAPE_CIRCLE then
		currentPlayerShape = SHAPE_CROSS
	else
		currentPlayerShape = SHAPE_CIRCLE
	end
end

function isValidCellX(x)
	return x and x >= 1 and x <= cols
end

function isValidCellY(y)
	return y and y >= 1 and y <= rows
end


function isValidCellXY(x, y)
	return isValidCellX(x) and isValidCellY(y)
end

function hasCurrentPlayerWin(cell)

	local gridPos = cellIdToXY(cell)
	local x = gridPos.x
	local y = gridPos.y

	local horizontal = true
	for cx=1, cols do
		local idx = getCellIdFromXY(cx, y)
		local currentCellShape = grid[idx]
		if currentCellShape ~= currentPlayerShape then
			horizontal = false
			break
		end
	end

	if horizontal then
		return true
	end

	local vertical = true
	for cy=1, rows do
		local idx = getCellIdFromXY(x, cy)
		local currentCellShape = grid[idx]
		if currentCellShape ~= currentPlayerShape then
			vertical = false
			break
		end
	end

	if vertical then
		return true
	end

	local topLeftX = x
	local topLeftY = y

	local topRightX = x
	local topRightY = y

	local leftWalk = true
	local rightWalk = true

	while leftWalk or rightWalk do
		if isValidCellXY(topLeftX - 1, topLeftY - 1) then
			topLeftX = topLeftX - 1
			topLeftY = topLeftY - 1
		else
			leftWalk = false
		end

		if isValidCellXY(topRightX + 1, topRightY - 1) then
			topRightX = topRightX + 1
			topRightY = topRightY - 1
		else
			rightWalk = false
		end
	end

	local validCellsCount = 0
	while isValidCellXY(topLeftX, topLeftY) do
		local idx = getCellIdFromXY(topLeftX, topLeftY)
		local currentCellShape = grid[idx]

		if currentCellShape == currentPlayerShape then
			validCellsCount = validCellsCount + 1
		else
			break
		end

		topLeftX = topLeftX + 1
		topLeftY = topLeftY + 1
	end

	if validCellsCount == diagonalCellsCount then
		return true
	end

	validCellsCount = 0

	while isValidCellXY(topRightX, topRightY) do
		local idx = getCellIdFromXY(topRightX, topRightY)
		local currentCellShape = grid[idx]

		if currentCellShape == currentPlayerShape then
			validCellsCount = validCellsCount + 1
		else
			break
		end

		topRightX = topRightX - 1
		topRightY = topRightY + 1
	end

	if validCellsCount == diagonalCellsCount then
		return true
	end

	return false
end

function onCellClick(cell)
	if grid[cell] == SHAPE_UNSET then
		grid[cell] = currentPlayerShape
		occupiedCells = occupiedCells + 1
		local draw = occupiedCells == cols * rows
		local win = hasCurrentPlayerWin(cell)
		if win or draw then
			playerWonTimer = 3.0
			if win then
				playerWonShape = currentPlayerShape
			else
				matchDraw = true
			end

			resetPlayground()
		end

		switchPlayer()
	end
end

function resetPlayground()
	for i=1, #grid do
		grid[i] = SHAPE_UNSET
	end
	occupiedCells = 0
	currentRoundTime = 0.0
end

local wasMouseDown = false

-- love key press function

function love.keypressed(key)

	if key == "r" then
		resetPlayground()
	end

	if key == "escape" then
		love.event.quit()
	end
	
	onCellClick(tonumber(key))
	onCellClick(tonumber(string.sub(key, 3)))

end

function love.draw()
	if AI_ENABLE and currentPlayerShape == SHAPE_CIRCLE then
		onCellClick(MaxPlayerO(grid)[2])
	end
	
	-- love.graphics.clear(20, 20, 20)
	

	local wndWidth = love.graphics.getWidth()
	local wndHeight = love.graphics.getHeight()

	playgroundSize = wndWidth
	if wndHeight < playgroundSize then
		playgroundSize = wndHeight
	end
	cellSize = playgroundSize/cellsInRow

	playgroundPos = { x = wndWidth * 0.5 - playgroundSize * 0.5, y = wndHeight * 0.5 - playgroundSize * 0.5 }

	love.graphics.setLineWidth(4.0)

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", playgroundPos.x, playgroundPos.y, playgroundSize, playgroundSize)

	local dx = playgroundPos.x
	local dy = playgroundPos.y

	local mx = love.mouse.getX()
	local my = love.mouse.getY()

	local selCell = getCellIdFromPoint(mx, my)

	local mouseDown = love.mouse.isDown(1)
	if selCell and mouseDown and not wasMouseDown then
		onCellClick(selCell)
	end
	wasMouseDown = mouseDown

	local highlightCell = nil

	for y=1, rows do
		for x=1, cols do
			local idx = getCellIdFromXY(x, y)

			if idx == selCell then
				highlightCell = {x = dx, y = dy}
			end

			love.graphics.setColor(80/255, 80/255, 80/255)
			love.graphics.print(tostring(idx), dx+10, dy+10)

			love.graphics.setColor(50/255, 50/255, 50/255)

			love.graphics.rectangle("line", dx, dy, cellSize, cellSize)

			love.graphics.setColor(180/255, 180/255, 180/255)
			drawShape(grid[idx], dx + 10, dy + 10, cellSize - 20, cellSize - 20, 30)

			dx = dx + cellSize
		end

		dx = playgroundPos.x
		dy = dy + cellSize
	end

	if highlightCell then
		if grid[selCell] == SHAPE_UNSET then
			love.graphics.setColor(0, 255, 0)
		else
			love.graphics.setColor(255, 0, 0)
		end
		love.graphics.rectangle("line", highlightCell.x, highlightCell.y, cellSize, cellSize)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Gracz:\n\nCzas: "..tostring(math.ceil(ROUND_TIME - currentRoundTime)).."s", 5, 5)

	love.graphics.setLineWidth(1.5)
	drawShape(currentPlayerShape, 46, 5, 11, 11, 10)

	local dt = love.timer.getDelta()

	if playerWonTimer then
		playerWonTimer = playerWonTimer - dt
		if playerWonTimer <= 0.0 then
			playerWonTimer = nil
			matchDraw = false
			playerWonShape = SHAPE_UNSET
		else
			love.graphics.setColor(255, 255, 0)
			if matchDraw then
				love.graphics.print("Remis!", 100, 5)
			else
				love.graphics.print("Zwyciezyl gracz - " .. (playerWonShape == SHAPE_CROSS and "krzyzyk" or "kółko"), 100, 5)
			end
		end
	end

	currentRoundTime = currentRoundTime + dt
	if currentRoundTime >= ROUND_TIME then
		resetPlayground()
	end
end

-- eof