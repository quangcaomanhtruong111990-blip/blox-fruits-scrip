local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Đợi 1 giây để game tải xong hoàn toàn
task.wait(1)

-- 1. Di chuyển lên phía trước
local targetPosition = hrp.Position + (hrp.CFrame.LookVector * 10)
humanoid:MoveTo(targetPosition)

-- Thông báo bắt đầu
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Thông báo",
    Text = "Đang di chuyển và chuẩn bị nhảy 10 lần...",
    Duration = 3
})

-- Đợi nhân vật di chuyển xong (khoảng 1.5 giây)
task.wait(1.5)

-- 2. Tăng chiều cao khi nhảy (Mặc định là 50, chỉnh lên 100 để nhảy cao gấp đôi)
humanoid.JumpPower = 100

-- 3. Vòng lặp cho nhân vật nhảy 10 lần
for i = 1, 10 do
    humanoid.Jump = true -- Ép nhân vật nhảy
    print("Đã nhảy lần thứ:", i)
    task.wait(1) -- Đợi 1 giây giữa mỗi lần nhảy
end

-- Trả lại độ cao nhảy bình thường
humanoid.JumpPower = 50
