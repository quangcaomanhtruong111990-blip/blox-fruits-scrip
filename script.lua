-- Lấy thông tin nhân vật
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Script Di Chuyển",
    Text = "Đang tiến lên phía trước...",
    Duration = 3
})

-- Dịch chuyển nhân vật lên phía trước 10 studs (khoảng 2-3 bước chân)
hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
