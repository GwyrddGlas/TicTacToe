local crossSprite = nil
local naughtSprite = nil

function love.load()
    crossSprite = love.graphics.newImage("sprites/cross.png")
    naughtSprite = love.graphics.newImage("sprites/naught.png")
end

local function v2(x, y)
    return {x=x, y=y}
end

local function tprint (tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2 
    for k, v in pairs(tbl) do
      toprint = toprint .. string.rep(" ", indent)
      if (type(k) == "number") then
        toprint = toprint .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        toprint = toprint  .. k ..  "= "   
      end
      if (type(v) == "number") then
        toprint = toprint .. v .. ",\r\n"
      elseif (type(v) == "string") then
        toprint = toprint .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
      else
        toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
  end

local mousePos = v2(nil, nil)

local function getGridCell(x, y)
    local width = love.graphics.getWidth() / 3
    local height = love.graphics.getHeight() / 3
    local cellX = math.floor(x / width) + 1
    local cellY = math.floor(y / height) + 1
    return cellX, cellY
end

local crosses = {}
local naughts = {}

local currentPlayer = 'N'  -- Starting player, N for Naught, C for Cross

local function containsSymbol(array, x, y)
    for _, pos in ipairs(array) do
        if pos.x == x and pos.y == y then
            return true
        end
    end
    return false
end

local function checkDiagonals(symbolArray, cellX, cellY)
    return (containsSymbol(symbolArray, cellX-1, cellY-1) and containsSymbol(symbolArray, cellX+1, cellY+1)) or
           (containsSymbol(symbolArray, cellX-1, cellY+1) and containsSymbol(symbolArray, cellX+1, cellY-1))
end

local function checkHorizontal(symbolArray, y)
    for x = 1, 3 do
        if not containsSymbol(symbolArray, x, y) then
            return false
        end
    end
    return true
end

local function checkVertical(symbolArray, x)
    for y = 1, 3 do
        if not containsSymbol(symbolArray, x, y) then
            return false
        end
    end
    return true
end

local function checkDiagonal(symbolArray)
    -- Check first diagonal
    local win = true
    for i = 1, 3 do
        if not containsSymbol(symbolArray, i, i) then
            win = false
            break
        end
    end
    if win then return true end

    -- Check second diagonal
    win = true
    for i = 1, 3 do
        if not containsSymbol(symbolArray, i, 4 - i) then
            win = false
            break
        end
    end
    return win
end

local function checkForWin(symbol)
    local symbolArray = (symbol == 'N') and naughts or crosses

    -- Check each row and column
    for i = 1, 3 do
        if checkHorizontal(symbolArray, i) or checkVertical(symbolArray, i) then
            return true
        end
    end

    -- Check diagonals
    if checkDiagonal(symbolArray) then
        return true
    end

    return false
end

local function createNaught(cellX, cellY)
    table.insert(naughts, {x = cellX, y = cellY})
   -- print("Naught added at: " .. cellX .. ", " .. cellY)
   -- print("Naughts array: " .. tprint(naughts))

    currentPlayer = 'C'  -- Switch to Crosses
end

local function createCross(cellX, cellY)
    table.insert(crosses, {x = cellX, y = cellY})
   -- print("Cross added at: " .. cellX .. ", " .. cellY)
   -- print("Crosses array: " .. tprint(crosses))

    currentPlayer = 'N'  -- Switch to Naughts
end

local gameOver = false
local moveMade = false

function love.mousepressed(x, y, button, istouch, presses)
    if not gameOver then
        local cellX, cellY = getGridCell(x, y)

        if currentPlayer == 'N' and not containsSymbol(crosses, cellX, cellY) and not containsSymbol(naughts, cellX, cellY) then
            createNaught(cellX, cellY)
            currentPlayer = 'C'
            moveMade = true
        elseif currentPlayer == 'C' and not containsSymbol(naughts, cellX, cellY) and not containsSymbol(crosses, cellX, cellY) then
            createCross(cellX, cellY)
            currentPlayer = 'N'
            moveMade = true
        end
    end
end

function love.update(dt)
    if not gameOver and moveMade then
        if currentPlayer == 'N' and checkForWin('C') then
            print("Crosses win!")
            gameOver = true
        elseif currentPlayer == 'C' and checkForWin('N') then
            print("Naughts win!")
            gameOver = true
        end
        moveMade = false
    end
end

local function drawMap()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    love.graphics.setColor(1, 1, 1, 1)  -- White background 
    love.graphics.rectangle("fill", 0, 0, width, height)

    love.graphics.setColor(0, 0, 0, 1)  -- Black color for the grid

    -- Draw vertical grid lines
    for i = 1, 2 do
        love.graphics.rectangle("fill", i * width / 3 - 5, 0, 10, height)
    end

    -- Draw horizontal grid lines
    for i = 1, 2 do
        love.graphics.rectangle("fill", 0, i * height / 3 - 5, width, 10)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function love.draw()
    drawMap()

    local cellWidth = love.graphics.getWidth() / 3
    local cellHeight = love.graphics.getHeight() / 3

    -- Draw naughts
    for i, pos in ipairs(naughts) do
        local drawX = (pos.x - 1) * cellWidth + (cellWidth - naughtSprite:getWidth()) / 2
        local drawY = (pos.y - 1) * cellHeight + (cellHeight - naughtSprite:getHeight()) / 2
        love.graphics.draw(naughtSprite, drawX, drawY)
    end
    
    -- Draw crosses
    for i, pos in ipairs(crosses) do
        local drawX = (pos.x - 1) * cellWidth + (cellWidth - crossSprite:getWidth()) / 2
        local drawY = (pos.y - 1) * cellHeight + (cellHeight - crossSprite:getHeight()) / 2
        love.graphics.draw(crossSprite, drawX, drawY)
    end
end