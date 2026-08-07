local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Thông báo kích hoạt
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Quái",
    Text = "Đang quét quái xung quanh để đánh...",
    Duration = 3
})

-- Hàm tìm con quái gần nhân vật nhất trong phạm vi (Radius)
local function getClosestMob(maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    -- Duyệt qua tất cả các đối tượng nằm trong thư mục Enemies của Blox Fruits
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            local mobHumanoid = mob:FindFirstChild("Humanoid")
            
            -- Kiểm tra quái còn sống và có bộ phận chính
            if mobHrp and mobHumanoid and mobHumanoid.Health > 0 then
                local distance = (hrp.Position - mobHrp.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestMob = mob
                end
            end
        end
    end
    return closestMob
end

-- Vòng lặp tự động Farm
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Quét quái trong phạm vi 300 studs
            local targetMob = getClosestMob(300)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Nâng quái lên cao 12 studs và tắt va chạm để không bị rớt xuống
                mobHrp.CFrame = mobHrp.CFrame * CFrame.new(0, 12, 0)
                mobHrp.CanCollide = false
                
                -- Teleport đứng ngay trên đầu quái 5 studs (để quái không đánh trúng mình)
                character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 5, 0)
                
                -- Tự động click chuột/nhấp màn hình để vung vũ khí đánh
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0, 0))
            end
        end)
    end
end)
