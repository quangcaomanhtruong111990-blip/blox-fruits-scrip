-- Đợi game load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Đợi player tồn tại
while not player do
    task.wait()
    player = Players.LocalPlayer
end

-- Đợi character spawn (sau khi chọn phe)
player.CharacterAdded:Wait()
local char = player.Character

print("SCRIPT OK - CHARACTER SPAWNED")
print("Player:", player.Name)
print("Character:", char.Name)
