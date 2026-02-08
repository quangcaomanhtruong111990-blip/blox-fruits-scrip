-- Đợi game load xong
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Đợi LocalPlayer tồn tại
while not player do
    task.wait()
    player = Players.LocalPlayer
end

print("SCRIPT LOADED OK")
print("Player Name:", player.Name)
print("UserId:", player.UserId)
