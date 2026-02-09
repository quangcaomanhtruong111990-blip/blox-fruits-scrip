--====================================
-- Project: Blox Fruits Lua Learning
-- Author: thienphucs06
-- Purpose: Learn Lua logic (SAFE)
--====================================

-- 1. In ra màn hình
print("Hello Lua")
print("Welcome to learning Lua for Roblox")

-- 2. Biến cơ bản
local level = 1
local beli = 500
local playerName = "Player"

print("Level:", level)
print("Beli:", beli)
print("Name:", playerName)

-- 3. Điều kiện
if level < 10 then
    print("Level còn thấp, cần train thêm")
else
    print("Level ổn rồi")
end

-- 4. Vòng lặp
for i = 1, 5 do
    print("Lần lặp:", i)
end

-- 5. Hàm
local function sayHello(name)
    print("Hello", name)
end

sayHello(playerName)
