local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Fix",
    Text = "Đã sửa lỗi tự trang bị và đánh quái!",
    Duration = 3
})

-- Hàm tự cầm vũ khí (Ưu tiên Melee/Combat hoặc Sword)
local function equipWeapon()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not character or not backpack then return end
    
    -- Nếu chưa cầm vũ khí nào trên tay
    if not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                character.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

-- Hàm tìm quái gần nhất
local function getClosestMob(maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            local mobHumanoid = mob:FindFirstChild("Humanoid")
            
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

-- Vòng lặp Farm chính
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- 1. Tự động lôi vũ khí ra tay
            equipWeapon()
            
            -- 2. Tìm quái trong bán kính 300 studs
            local targetMob = getClosestMob(300)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Bay tới giữ khoảng cách 4 studs trên đầu quái
                character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 4, 0)
                
                -- 3. Ép vũ khí đang cầm thực hiện đòn đánh (Activate)
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                -- Giả lập bấm chuột trái trên màn hình
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end)
    end
end)
