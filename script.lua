local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Đợi 1 giây để game tải xong hoàn toàn
task.wait(1)

-- Tính vị trí phía trước mặt 10 bước
local targetPosition = hrp.Position + (hrp.CFrame.LookVector * 10)

-- Ép nhân vật tự bước đi tới vị trí đó
humanoid:MoveTo(targetPosition)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Thành công!",
    Text = "Nhân vật đang tự đi tới!",
    Duration = 3
})
