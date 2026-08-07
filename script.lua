local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Walk",
    Text = "Nhân vật bắt đầu đi tới liên tục!",
    Duration = 3
})

-- Vòng lặp liên tục ép nhân vật đi về phía trước
task.spawn(function()
    while true do
        -- Move hướng theo LookVector (mặt nhân vật nhìn về đâu sẽ đi về đó)
        humanoid:Move(hrp.CFrame.LookVector, true)
        task.wait() -- Nghỉ mỗi khung hình để game không bị lag/văng
    end
end)
