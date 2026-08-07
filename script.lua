local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Fix Auto Farm",
    Text = "Đã tối ưu khoảng cách an toàn & tốc độ đánh!",
    Duration = 3
})

-- 1. Hàm cầm vũ khí (Chỉ chạy khi chưa cầm gì trên tay)
local function equipWeapon()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not character or not backpack then return end
    
    if not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Blox Fruit") then
                character.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

-- 2. Hàm tìm quái gần nhất
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

-- Tự động cầm sẵn vũ khí ngay từ đầu
equipWeapon()

-- 3. Vòng lặp Farm chính
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Đảm bảo luôn cầm vũ khí
            equipWeapon()
            
            local targetMob = getClosestMob(300)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Đứng cao trên đầu quái 8 studs (Quái hoàn toàn không đánh tới)
                character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 8, 0)
                
                -- Kích hoạt đòn đánh bằng Tool
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                -- Giả lập click đánh trên màn hình
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end)
    end
end)
