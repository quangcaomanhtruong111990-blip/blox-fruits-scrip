local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Walk",
    Text = "Đã kích hoạt tự động đi tới!",
    Duration = 3
})

-- Tạo vòng lặp di chuyển liên tục theo thời gian thực
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    if humanoid and hrp then
        -- Ép nhân vật di chuyển liên tục theo hướng mặt đang nhìn
        humanoid:Move(hrp.CFrame.LookVector, false)
    end
end)
