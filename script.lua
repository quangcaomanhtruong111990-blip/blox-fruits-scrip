local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Bay Cao",
    Text = "Đã tăng độ cao an toàn lên 14 studs!",
    Duration = 3
})

-- 1. Hàm tự cầm vũ khí
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

-- 3. Vòng lặp Farm bay cao an toàn
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            equipWeapon()
            local targetMob = getClosestMob(300)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Nâng độ cao lên 14 studs (Cách xa tầm đánh của quái Sea 2)
                character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 14, 0)
                
                -- Giữ nhân vật không bị rơi
                character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                
                -- Thực hiện đòn đánh
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end)
    end
end)
