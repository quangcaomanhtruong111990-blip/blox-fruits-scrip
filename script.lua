print("SCRIPT LOADED OK")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

if player then
    print("Player Name:", player.Name)
    print("UserId:", player.UserId)
else
    warn("No LocalPlayer")
end

